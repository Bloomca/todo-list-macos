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
    private var isLoading: Bool { projectStore.isLoading }
    private var noProjects: Bool { projectStore.isLoaded && projects.isEmpty }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedProject) {
                Section("List of projects") {
                    
                    if noProjects {
                        Text("No projects yet. Create one!")
                    }
                    
                    if isLoading {
                        LoaderView()
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
            if let projectId = selectedProject {
                ProjectView(projectId: projectId)
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
