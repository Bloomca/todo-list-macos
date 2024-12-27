//
//  AppView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var projectStore: ProjectStore
    
    @State private var selectedProject: Int?
    @State private var addingNewProject: Bool = false
    
    private var projects: [Project] { projectStore.getProjects() }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedProject) {
                Section("List of projects") {
                    
                    if projects.isEmpty {
                        Text("No projects yet. Create one!")
                    }
                    
                    ForEach(projects) { project in
                        NavigationLink(value: 1) {
                            Label(project.name, systemImage: "gauge")
                        }
                    }
                }
                
                Section("Actions") {
                    Button(action: {
                        addingNewProject = true
                    }) {
                        Label("Add new project", systemImage: "plus.circle.fill")
                    }
                }
            }
            .listStyle(.sidebar)
        } detail: {
            if let selection = selectedProject {
                Text("You selected \(selection)")
            } else {
                Text("No project selected")
            }
        }
        .sheet(isPresented: $addingNewProject) {
            AddProjectView(selectedId: $selectedProject,
                           addingNewProject: $addingNewProject)
        }
        .onAppear {
            Task {
                await projectStore.fetchProjects()
            }
        }
    }
}

#Preview {
    AppView()
}
