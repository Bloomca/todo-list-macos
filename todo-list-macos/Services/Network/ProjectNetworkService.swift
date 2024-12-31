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

struct UpdateProjectRequest: NetworkRequest, Encodable {
    var name: String?
    var description: String?
    var isArchived: Bool?
    var displayOrder: Int?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Only encode non-nil values
        try name.map { try container.encode($0, forKey: .name) }
        try description.map { try container.encode($0, forKey: .description) }
        try isArchived.map { try container.encode($0, forKey: .isArchived) }
        try displayOrder.map { try container.encode($0, forKey: .displayOrder) }
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case isArchived
        case displayOrder
    }
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
        let _: EmptyResponse = try await baseNetworkService.request(
            path: "/projects/\(projectId)",
            method: NetworkMethod.delete,
            body: nil as EmptyBody?,
            expectedCode: 204,
            token: token)
    }
    
    func updateProject(token: String,
                       projectId: Int,
                       name: String? = nil,
                       description: String? = nil,
                       isArchived: Bool? = nil,
                       displayOrder: Int? = nil) async throws {
        let request = UpdateProjectRequest(name: name,
                                           description: description,
                                           isArchived: isArchived,
                                           displayOrder: displayOrder)

        let _: EmptyResponse = try await baseNetworkService.request(
            path: "/projects/\(projectId)",
            method: NetworkMethod.put,
            body: request,
            expectedCode: 204,
            token: token)
    }
}
