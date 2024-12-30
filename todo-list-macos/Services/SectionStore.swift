//
//  SectionStore.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/28/24.
//

import Foundation

struct SectionEntity: NetworkResponse, Identifiable {
    let id: Int
    let projectId: Int
    let name: String
    let isArchived: Bool
    let createdAt: String
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
    
    func onProjectDelete(projectId: Int) {
        self.sections.removeAll { $0.projectId == projectId }
    }
}
