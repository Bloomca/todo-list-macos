//
//  AddProjectView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import SwiftUI

struct ProjectEditor: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var projectStore: ProjectStore
    
    var project: Project?
    var onSave: ((_ project: Project) -> Void)?
    
    @State private var isSavingProject: Bool = false
    @State private var savingProjectError: Error?
    
    @State private var projectName: String = ""
    @State private var projectDescription: String = ""
    
    init(project: Project? = nil, onSave: ((_ project: Project) -> Void)? = nil) {
        self.project = project
        self.onSave = onSave
        
        if let project {
            _projectName = State(initialValue: project.name)
            _projectDescription = State(initialValue: project.description)
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(project == nil ? "Create a new project" : "Edit project")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                TextField("Project name", text: $projectName)
                    .modifier(CustomTextField())

                TextField("Project description (optional)", text: $projectDescription)
                    .modifier(CustomTextField())
            }
            
            if savingProjectError != nil {
                Text("Error during project creation")
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
            
            HStack {
                Button {
                    dismiss()
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
                            savingProjectError = nil
                            isSavingProject = true
                            
                            if let project {
                                let updatedProject = try await projectStore.updateProject(
                                    projectId: project.id, name: projectName, description: projectDescription)
                                
                                if let onSave { onSave(updatedProject) }
                            } else {
                                let project = try await projectStore.createProject(
                                    name: projectName,
                                    description: projectDescription)
                                
                                if let onSave { onSave(project) }
                            }
                            
                            isSavingProject = false
                            dismiss()
                        } catch {
                            isSavingProject = false
                            savingProjectError = error
                            print("error creating project: \(error)")
                        }
                    }
                } label: {
                    Text(project == nil ? "Create" : "Update")
                        .frame(minWidth: 80)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(.teal)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(isSavingProject || projectName.isEmpty)
            }
        }
        .padding(24)
        .frame(maxWidth: 400)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 2)
    }
}
