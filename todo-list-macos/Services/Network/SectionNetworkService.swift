//
//  SectionNetworkService.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/28/24.
//

import Foundation

struct CreateSectionRequest: NetworkRequest {
    let projectId: Int
    let name: String
}

struct UpdateSectionRequest: NetworkRequest, Encodable {
    var name: String?
    var isArchived: Bool?
    var displayOrder: Int?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Only encode non-nil values
        try name.map { try container.encode($0, forKey: .name) }
        try isArchived.map { try container.encode($0, forKey: .isArchived) }
        try displayOrder.map { try container.encode($0, forKey: .displayOrder) }
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case isArchived
        case displayOrder
    }
}

struct SectionNetworkService {
    private let baseNetworkService: BaseNetworkService
    
    init(baseNetworkService: BaseNetworkService) {
        self.baseNetworkService = baseNetworkService
    }
    
    func getProjectSections(token: String, projectId: Int) async throws -> [SectionEntity] {
        let sections: [SectionEntity] = try await baseNetworkService.request(
            path: "/sections",
            queryParameters: ["project_id": projectId],
            method: .get,
            body: nil as EmptyBody?,
            expectedCode: 200,
            token: token)

        return sections
    }
    
    func createSection(token: String, projectId: Int, name: String) async throws -> SectionEntity {
        let request = CreateSectionRequest(projectId: projectId, name: name)
        let createdSection: SectionEntity = try await baseNetworkService.request(
            path: "/sections",
            method: .post,
            body: request,
            expectedCode: 201,
            token: token)
        
        return createdSection
    }
    
    func deleteSection(token: String, sectionId: Int) async throws {
        let _: EmptyResponse = try await baseNetworkService.request(
            path: "/sections/\(sectionId)",
            method: NetworkMethod.delete,
            body: nil as EmptyBody?,
            expectedCode: 204,
            token: token)
    }
    
    func updateSection(token: String,
                       sectionId: Int,
                       name: String? = nil,
                       isArchived: Bool? = nil,
                       displayOrder: Int? = nil) async throws {
        let request = UpdateSectionRequest(name: name,
                                           isArchived: isArchived,
                                           displayOrder: displayOrder)

        let _: EmptyResponse = try await baseNetworkService.request(
            path: "/sections/\(sectionId)",
            method: NetworkMethod.put,
            body: request,
            expectedCode: 204,
            token: token)
    }
}
