//
//  ProjectStore.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import Foundation

struct Project: NetworkResponse, Identifiable {
    let id: Int
    let name: String
    let description: String
    let isArchived: Bool
    let createdAt: String
    
    func copyWith(
        id: Int? = nil,
        name: String? = nil,
        description: String? = nil,
        isArchived: Bool? = nil,
        createdAt: String? = nil
    ) -> Project {
        Project(
            id: id ?? self.id,
            name: name ?? self.name,
            description: description ?? self.description,
            isArchived: isArchived ?? self.isArchived,
            createdAt: createdAt ?? self.createdAt
        )
    }
}

@MainActor
class ProjectStore: ObservableObject {
    // dependencies
    private var authStore: AuthStore
    
    var isLoaded: Bool = false
    @Published var isLoading: Bool = false
    @Published var fetchError: Error? = nil
    @Published var projectsById: [Int: Project] = [:]
    
    init(authStore: AuthStore) {
        self.authStore = authStore
    }
    
    func fetchProjects() async {
        if (isLoaded) { return }
        if (isLoading) { return }
                
        do {
            let token = try authStore.getToken()
            isLoading = true
            let projects = try await projectNetworkService.getProjects(token: token)
            isLoading = false
            for project in projects {
                projectsById[project.id] = project
            }
        } catch {
            isLoading = false
            fetchError = error
        }
    }
    
    func createProject(name: String, description: String) async throws -> Project {
        let token = try authStore.getToken()
        let project = try await projectNetworkService.createProject(token: token, name: name, description: description)
        
        projectsById[project.id] = project
        
        return project
    }
    
    func deleteProject(projectId: Int, onDelete: () -> Void) async throws {
        let token = try authStore.getToken()
        try await projectNetworkService.deleteProject(token: token, projectId: projectId)
        
        // execute on delete callback like navigating away from the view first
        onDelete()
        projectsById.removeValue(forKey: projectId)
    }
    
    func archiveProject(projectId: Int, onArchive: () -> Void) async throws {
        let token = try authStore.getToken()
        try await projectNetworkService.updateProject(
            token: token, projectId: projectId, isArchived: true)
        
        onArchive()
        
        let currentProject = projectsById[projectId]
        if let currentProject {
            projectsById[projectId] = currentProject.copyWith(isArchived: true)
        }
    }

    func getProjects() -> [Project] {
        Array(projectsById.values).filter { !$0.isArchived }.sorted { $0.createdAt < $1.createdAt }
    }
    
    func getArchivedProjects() -> [Project] {
        // ideally, we should add `archivedAt` field. This sorting is just to have consistent order
        Array(projectsById.values).filter(\.isArchived).sorted { $0.createdAt < $1.createdAt }
    }
}
