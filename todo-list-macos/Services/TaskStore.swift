//
//  TaskStore.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/27/24.
//

import Foundation

struct TaskEntity: NetworkResponse, Identifiable {
    let id: Int
    let projectId: Int
    let sectionId: Int?
    let name: String
    let description: String
    let isCompleted: Bool
    let isArchived: Bool
}

class TaskData {
    var isLoading: Bool = false
    var isLoaded: Bool = false
    var fetchError: Error? = nil
    var tasks: [TaskEntity] = []
}

@MainActor
class TaskStore: ObservableObject {
    // dependencies
    private var authStore: AuthStore
    
    @Published var loadingTasksByProject: [Int: Bool] = [:]
    @Published var loadedTasksByProject: [Int: Bool] = [:]
    @Published var errorTasksByProject: [Int: Error] = [:]
    @Published var tasks: [TaskEntity] = []
    
    init(authStore: AuthStore) {
        self.authStore = authStore
    }
    
    func fetchProjectTasks(projectId: Int) async {
        if loadedTasksByProject[projectId] == true { return }
        if loadingTasksByProject[projectId] == true { return }
        
        do {
            if errorTasksByProject[projectId] != nil {
                errorTasksByProject.removeValue(forKey: projectId)
            }
            loadingTasksByProject[projectId] = true
            let token = try authStore.getToken()
            let projectTasks = try await taskNetworkService.getProjectTasks(token: token, projectId: projectId)
            loadingTasksByProject[projectId] = false
            loadedTasksByProject[projectId] = true
            self.tasks.append(contentsOf: projectTasks)
        } catch {
            loadingTasksByProject[projectId] = false
            errorTasksByProject[projectId] = error
        }
    }
    
    func createTask(projectId: Int, name: String, description: String) async throws {
        let token = try authStore.getToken()
        let newTask = try await taskNetworkService.createTask(token: token,
                                                              projectId: projectId,
                                                              name: name,
                                                              description: description)
        
        tasks.append(newTask)
    }
}