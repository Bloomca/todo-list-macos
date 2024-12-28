//
//  ProjectView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/27/24.
//

import SwiftUI

struct ProjectView: View {
    @EnvironmentObject private var projectStore: ProjectStore
    @EnvironmentObject private var taskStore: TaskStore
    
    let projectId: Int
    
    var project: Project? { projectStore.projectsById[projectId] }
    var isLoading: Bool { taskStore.loadingTasksByProject[projectId] ?? false }
    var tasks: [TaskEntity] { taskStore.tasks.filter { $0.projectId == projectId } }
    var noTasks: Bool {
        if taskStore.loadedTasksByProject[projectId] == true {
            return tasks.isEmpty
        }
        
        return false
    }
    
    var body: some View {
        if let project {
            VStack(spacing: 0) {
                HStack {
                    Text(project.name)
                        .font(.title2)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .frame(width: .infinity)
                .background(.black.opacity(0.5))
                
                Spacer()
                    .frame(height: 16)
                
                if isLoading {
                    LoaderView()
                }
                
                if noTasks {
                    Text("You have no tasks in this project!")
                }
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(tasks) { task in
                            TaskView(task: task)
                            
                            Divider()
                        }
                    }
                }
                
                InlineTaskEditor(projectId: projectId)
                    .padding(.bottom, 8)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .onChange(of: projectId) {
                Task {
                    await taskStore.fetchProjectTasks(projectId: projectId)
                }
            }
            .onAppear {
                Task {
                    await taskStore.fetchProjectTasks(projectId: projectId)
                }
            }
        } else {
            Text("No project found")
        }
    }
}

#Preview {
    ProjectView(projectId: 1)
}
