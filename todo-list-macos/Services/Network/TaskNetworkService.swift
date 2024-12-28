//
//  TaskNetworkService.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/27/24.
//

import Foundation

struct CreateTaskRequest: NetworkRequest {
    let projectId: Int
    let name: String
    let description: String
}

struct TaskNetworkService {
    private let baseNetworkService: BaseNetworkService
    
    init(baseNetworkService: BaseNetworkService) {
        self.baseNetworkService = baseNetworkService
    }
    
    func getProjectTasks(token: String, projectId: Int) async throws -> [TaskEntity] {
        let tasks: [TaskEntity] = try await baseNetworkService.request(
            path: "/tasks",
            queryParameters: ["project_id": projectId],
            method: .get,
            body: nil as EmptyBody?,
            expectedCode: 200,
            token: token)

        return tasks
    }
    
    func createTask(token: String, projectId: Int, name: String, description: String = "") async throws -> TaskEntity {
        let request = CreateTaskRequest(projectId: projectId, name: name, description: description)
        let createdTask: TaskEntity = try await baseNetworkService.request(
            path: "/tasks",
            method: .post,
            body: request,
            expectedCode: 201,
            token: token)
        
        return createdTask
    }
}
