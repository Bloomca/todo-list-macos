//
//  SectionActionsView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/31/24.
//

import SwiftUI

struct SectionActionsView: View {
    @EnvironmentObject var sectionStore: SectionStore
    @EnvironmentObject var taskStore: TaskStore
    
    var section: SectionEntity
    
    @Binding var editingSection: Bool
    
    @State private var deletingSection: Bool = false
    @State private var deletingError: Error? = nil
    
    @State private var archivingSection: Bool = false
    @State private var archivingError: Error? = nil
    
    var body: some View {
        HStack {
            Button {
                deletingSection = true
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(CustomIconButtonStyle())
            if section.isArchived() {
                Button {
                    Task {
                        do {
                            try await sectionStore.unarchiveSection(sectionId: section.id)
                        } catch {
                            // TODO: add some sort of notification/toast to show the error
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.bin")
                }
                .buttonStyle(CustomIconButtonStyle())
            } else {
                Button {
                    archivingSection = true
                } label: {
                    Image(systemName: "archivebox")
                }
                .buttonStyle(CustomIconButtonStyle())
            }
            Button {
                editingSection = true
            } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(CustomIconButtonStyle())
        }
        .sheet(isPresented: $deletingSection) {
            ConfirmationModalView(
                title: "Delete section?",
                confirmTitle: "Delete",
                description: "All its tasks will be deleted as well. This action cannot be undone.",
                errorTitle: deletingError != nil ? "Error while deleting section" : nil,
                onCancel: { deletingSection = false },
                onConfirm: {
                    Task {
                        do {
                            deletingError = nil
                            try await sectionStore.deleteSection(sectionId: section.id) {
                                taskStore.onSectionDelete(sectionId: section.id)
                            }
                            deletingSection = false
                        } catch {
                            deletingError = error
                        }
                    }
                }
            )
        }
        .sheet(isPresented: $archivingSection) {
            ConfirmationModalView(
                title: "Archive section?",
                confirmTitle: "Archive",
                description: "You can unarchive the section later, all its tasks will be preserved.",
                errorTitle: archivingError != nil ? "Error while archiving section" : nil,
                onCancel: { archivingSection = false },
                onConfirm: {
                    Task {
                        do {
                            archivingError = nil
                            try await sectionStore.archiveSection(sectionId: section.id)
                            archivingSection = false
                        } catch {
                            archivingError = error
                        }
                    }
                }
            )
        }
    }
}
