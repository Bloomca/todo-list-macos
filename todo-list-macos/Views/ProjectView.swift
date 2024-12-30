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
    @EnvironmentObject private var sectionStore: SectionStore
    
    let projectId: Int
    
    var project: Project? { projectStore.projectsById[projectId] }
    var areTasksLoading: Bool { taskStore.loadingTasksByProject[projectId] ?? false }
    var areSectionsLoading: Bool { sectionStore.loadingSectionsByProject[projectId] ?? false }
    var isLoading: Bool { areTasksLoading || areSectionsLoading }
    var tasks: [TaskEntity] { taskStore.tasks.filter { $0.projectId == projectId && $0.sectionId == nil } }
    var sections: [SectionEntity] { sectionStore.sections.filter { $0.projectId == projectId } }
    
    var body: some View {
        if project != nil {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 16)
                
                if isLoading {
                    LoaderView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(tasks) { task in
                                TaskView(task: task)
                                
                                Divider()
                            }
                            
                            InlineTaskEditor(projectId: projectId)
                                .padding(.bottom, 8)
                            
                            InlineSectionEditor(projectId: projectId)
                            
                            ForEach(sections) { section in
                                SectionView(section: section)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .onChange(of: projectId) {
                Task {
                    await sectionStore.fetchProjectSections(projectId: projectId)
                    await taskStore.fetchProjectTasks(projectId: projectId)
                }
            }
            .onAppear {
                Task {
                    await sectionStore.fetchProjectSections(projectId: projectId)
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
