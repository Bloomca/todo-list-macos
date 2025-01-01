//
//  SectionStore.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/28/24.
//

import Foundation

enum SectionStoreError: Error {
    case genericError(message: String)
}

struct SectionEntity: NetworkResponse, Identifiable {
    let id: Int
    let projectId: Int
    let name: String
    let archivedAt: String?
    let createdAt: String
    
    func isArchived() -> Bool {
        archivedAt != nil
    }
    
    func copyWith(
        projectId: Int? = nil,
        name: String? = nil
    ) -> SectionEntity {
        SectionEntity(
            id: self.id,
            projectId: projectId ?? self.projectId,
            name: name ?? self.name,
            archivedAt: self.archivedAt,
            createdAt: self.createdAt
        )
    }
    
    // use this method to change archived status to avoid problems with `nil`
    func changeArchivedStatus(_ newArchivedAt: String?) -> SectionEntity {
        SectionEntity(
            id: self.id,
            projectId: self.projectId,
            name: self.name,
            archivedAt: newArchivedAt,
            createdAt: self.createdAt
        )
    }
}

@MainActor
class SectionStore: ObservableObject {
    // dependencies
    private var authStore: AuthStore
    
    @Published var loadingSectionsByProject: [Int: Bool] = [:]
    @Published var loadedSectionsByProject: [Int: Bool] = [:]
    @Published var errorSectionsByProject: [Int: Error] = [:]
    @Published var sections: [SectionEntity] = []
    
    init(authStore: AuthStore) {
        self.authStore = authStore
    }
    
    func fetchProjectSections(projectId: Int) async {
        if loadingSectionsByProject[projectId] == true { return }
        if loadedSectionsByProject[projectId] == true { return }
        
        do {
            if errorSectionsByProject[projectId] != nil {
                errorSectionsByProject.removeValue(forKey: projectId)
            }
            loadingSectionsByProject[projectId] = true
            let token = try authStore.getToken()
            let projectSections = try await sectionNetworkService.getProjectSections(token: token, projectId: projectId)
            loadingSectionsByProject[projectId] = false
            loadedSectionsByProject[projectId] = true
            self.sections.append(contentsOf: projectSections)
        } catch {
            loadingSectionsByProject[projectId] = false
            errorSectionsByProject[projectId] = error
        }
    }
    
    func createSection(projectId: Int, name: String) async throws {
        let token = try authStore.getToken()
        let newSection = try await sectionNetworkService.createSection(
            token: token,
            projectId: projectId,
            name: name)
        
        sections.append(newSection)
    }
    
    func deleteSection(sectionId: Int, onDelete: () -> Void) async throws {
        let token = try authStore.getToken()
        try await sectionNetworkService.deleteSection(token: token, sectionId: sectionId)

        onDelete()
        self.sections.removeAll { $0.id == sectionId }
    }
    
    func archiveSection(sectionId: Int) async throws {
        let token = try authStore.getToken()
        try await sectionNetworkService.updateSection(
            token: token, sectionId: sectionId, isArchived: true)
        
        self.sections = self.sections.map { section in
            if section.id == sectionId {
                return section.changeArchivedStatus("2024-12-31")
            }
            
            return section
        }
    }
    
    func unarchiveSection(sectionId: Int) async throws {
        let token = try authStore.getToken()
        try await sectionNetworkService.updateSection(
            token: token, sectionId: sectionId, isArchived: false)
        
        self.sections = self.sections.map { section in
            if section.id == sectionId {
                return section.changeArchivedStatus(nil)
            }
            
            return section
        }
    }
    
    func updateSection(sectionId: Int, name: String) async throws {
        let token = try authStore.getToken()
        
        try await sectionNetworkService.updateSection(
            token: token, sectionId: sectionId, name: name)
        
        
        self.sections = self.sections.map { section in
            if section.id == sectionId {
                return section.copyWith(name: name)
            }
            
            return section
        }
    }
    
    func onProjectDelete(projectId: Int) {
        self.sections.removeAll { $0.projectId == projectId }
    }
}
