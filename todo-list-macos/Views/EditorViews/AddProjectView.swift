//
//  AddProjectView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import SwiftUI

struct AddProjectView: View {
    @EnvironmentObject var projectStore: ProjectStore
    
    @Binding var selectedId: Int?
    @Binding var addingNewProject: Bool
    
    @State private var isCreatingProject: Bool = false
    @State private var creatingProjectError: Error?
    
    @State private var projectName: String = ""
    @State private var projectDescription: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Create a new project")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                TextField("Project name", text: $projectName)
                    .modifier(CustomTextField())

                TextField("Project description (optional)", text: $projectDescription)
                    .modifier(CustomTextField())
            }
            
            if creatingProjectError != nil {
                Text("Error during project creation")
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
            
            HStack {
                Button {
                    addingNewProject = false
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
                            creatingProjectError = nil
                            isCreatingProject = true
                            let project = try await projectStore.createProject(
                                name: projectName,
                                description: projectDescription)
                            
                            selectedId = project.id
                            isCreatingProject = false
                            addingNewProject = false
                        } catch {
                            isCreatingProject = false
                            creatingProjectError = error
                            print("error creating project: \(error)")
                        }
                    }
                } label: {
                    Text("Create")
                        .frame(minWidth: 80)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(.teal)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(isCreatingProject || projectName.isEmpty)
            }
        }
        .padding(24)
        .frame(maxWidth: 400)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 2)
    }
}

#Preview {
    AddProjectView(selectedId: .constant(nil), addingNewProject: .constant(false))
}
