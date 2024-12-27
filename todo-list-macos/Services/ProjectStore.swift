//
//  ProjectStore.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import Foundation

struct Project: NetworkResponse, Decodable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let isArchived: Bool
    let createdAt: String
}

@MainActor
class ProjectStore: ObservableObject {
    // dependencies
    private var authStore: AuthStore
    
    private var isLoaded: Bool = false
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
    
    func getProjects() -> [Project] {
        Array(projectsById.values)
    }
}
