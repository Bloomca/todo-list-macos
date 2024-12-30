//
//  ProjectActionsView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/29/24.
//

import SwiftUI

struct ProjectActionsView: View {
    @EnvironmentObject private var projectStore: ProjectStore
    @EnvironmentObject private var taskStore: TaskStore
    @EnvironmentObject private var sectionStore: SectionStore
    
    @State private var deletingProject: Bool = false
    @State private var deletingError: Error? = nil
    
    var projectId: Int
    var project: Project? { projectStore.projectsById[projectId] }
    
    var onDeleteProject: () -> Void
    
    var body: some View {
        if project != nil {
            HStack {
                Button {
                    deletingProject = true
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(CustomIconButtonStyle())
                Button {
                    // pass
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(CustomIconButtonStyle())
                Button {
                    // pass
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .buttonStyle(CustomIconButtonStyle())
                Button {
                    // pass
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .buttonStyle(CustomIconButtonStyle())
            }
            .sheet(isPresented: $deletingProject) {
                VStack(spacing: 20) {
                    Text("Delete project?")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                    
                    if deletingError != nil {
                        Text("Error while deleting project")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                    
                    HStack(spacing: 12) {
                        Button {
                            deletingProject = false
                        } label: {
                            Text("Cancel")
                                .frame(minWidth: 80)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                                .background(.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            Task {
                                do {
                                    deletingError = nil
                                    try await projectStore.deleteProject(projectId: projectId) {
                                        onDeleteProject()
                                        sectionStore.onProjectDelete(projectId: projectId)
                                        taskStore.onProjectDelete(projectId: projectId)
                                    }
                                    deletingProject = false
                                } catch {
                                    deletingError = error
                                }
                            }
                        } label: {
                            Text("Delete")
                                .frame(minWidth: 80)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 8)
                                .background(.teal)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 8)
                }
                .padding(12)
                .frame(width: 260)
                .background(.background)
                .cornerRadius(12)
            }
        } else {
            EmptyView()
        }
    }
}
