//
//  ProjectStore.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import Foundation

struct Project: Decodable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let isArchived: Bool
    let createdAt: String
}

@MainActor
class ProjectStore: ObservableObject {
    private var isLoaded: Bool = false
    @Published var isLoading: Bool = false
    @Published var fetchError: Error? = nil
    @Published var projectsById: [Int: Project] = [:]
    
    func fetchProjects(token: String) async {
        if (isLoaded) { return }
        if (isLoading) { return }
        
        let fetchService = FetchService()
        
        do {
            isLoading = true
            let projects = try await fetchService.getProjects(token: token)
            isLoading = false
            for project in projects {
                projectsById[project.id] = project
            }
        } catch {
            isLoading = false
            fetchError = error
        }
    }
    
    func createProject(token: String, name: String, description: String) async throws -> Project {
        let fetchService = FetchService()
        
        let project = try await fetchService.createProject(token: token, name: name, description: description)
        
        projectsById[project.id] = project
        
        return project
    }
    
    func getProjects() -> [Project] {
        Array(projectsById.values)
    }
    
    
}
