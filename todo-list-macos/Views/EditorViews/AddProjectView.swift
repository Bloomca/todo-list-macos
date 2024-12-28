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
        VStack {
            Text("Create a new project")
                .font(.headline)
                .padding()
            
            TextField("Project name", text: $projectName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)
            TextField("Project description (optional)", text: $projectDescription)
                .textFieldStyle(.roundedBorder)
                .frame(width: 250)
            
            if creatingProjectError != nil {
                Text("Error during project creation")
            }
            
            HStack {
                Button("Cancel") {
                    addingNewProject = false
                }
                .buttonStyle(.borderedProminent)
                .tint(.gray.opacity(0.5))

                Button("Create") {
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
                }
                .buttonStyle(.borderedProminent)
                .disabled(isCreatingProject)
            }
            .padding(.bottom, 10)
        }
        .padding()
    }
}

#Preview {
    AddProjectView(selectedId: .constant(nil), addingNewProject: .constant(false))
}
