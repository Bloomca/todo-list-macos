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
    
    @State private var archivingProject: Bool = false
    @State private var archivingError: Error? = nil
    
    var projectId: Int
    var project: Project? { projectStore.projectsById[projectId] }
    
    var onDeleteProject: () -> Void
    
    var body: some View {
        if let project {
            HStack {
                Button {
                    deletingProject = true
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(CustomIconButtonStyle())
                if project.archivedAt != nil {
                    Button {
                        // TODO: add unarchiving
                        
                    } label: {
                        Image(systemName: "arrow.up.bin")
                    }
                    .buttonStyle(CustomIconButtonStyle())
                } else {
                    Button {
                        archivingProject = true
                    } label: {
                        Image(systemName: "archivebox")
                    }
                    .buttonStyle(CustomIconButtonStyle())
                }
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
                ConfirmationModalView(
                    title: "Delete project?",
                    confirmTitle: "Delete",
                    description: "All its tasks and sections will be deleted as well. This action cannot be undone.",
                    errorTitle: deletingError != nil ? "Error while deleting project" : nil,
                    onCancel: { deletingProject = false },
                    onConfirm: {
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
                    }
                )
            }
            .sheet(isPresented: $archivingProject) {
                ConfirmationModalView(
                    title: "Archive project?",
                    confirmTitle: "Archive",
                    description: "All its tasks and sections will be archived as well. You can unarchive it later.",
                    errorTitle: archivingError != nil ? "Error while archiving project" : nil,
                    onCancel: { archivingProject = false },
                    onConfirm: {
                        Task {
                            do {
                                archivingError = nil
                                try await projectStore.archiveProject(projectId: projectId)
                                archivingProject = false
                            } catch {
                                archivingError = error
                            }
                        }
                    }
                )
            }
        } else {
            EmptyView()
        }
    }
}
