//
//  ProjectNetworkService.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/27/24.
//

import Foundation

struct CreateProjectRequest: NetworkRequest {
    let name: String
    let description: String
}

struct ProjectNetworkService {
    private let baseNetworkService: BaseNetworkService
    
    init(baseNetworkService: BaseNetworkService) {
        self.baseNetworkService = baseNetworkService
    }
    
    func getProjects(token: String) async throws -> [Project] {
        let projects: [Project] = try await baseNetworkService.request(
            path: "/projects",
            method: .get,
            body: nil as EmptyBody?,
            expectedCode: 200,
            token: token)

        return projects
    }
    
    func createProject(token: String, name: String, description: String) async throws -> Project {
        let request = CreateProjectRequest(name: name, description: description)
        
        let response: Project = try await baseNetworkService.request(
            path: "/projects",
            method: .post,
            body: request,
            expectedCode: 201,
            token: token)
        
        return response
    }
    
    func deleteProject(token: String, projectId: Int) async throws {
        let response: EmptyResponse = try await baseNetworkService.request(
            path: "/projects/\(projectId)",
            method: NetworkMethod.delete,
            body: nil as EmptyBody?,
            expectedCode: 204,
            token: token)
    }
}
