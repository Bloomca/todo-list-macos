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
}
