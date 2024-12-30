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
    private var archivedProjects: [Project] { projectStore.getArchivedProjects() }
    private var currentTitle: String {
        if let selectedProject,
           let project = projectStore.projectsById[selectedProject] {
            return project.isArchived ? "\(project.name) (archived)" : project.name
        } else {
            return ""
        }
    }
    private var isLoading: Bool { projectStore.isLoading }
    private var noProjects: Bool { projectStore.isLoaded && projects.isEmpty }
    private var noArchivedProjects: Bool { projectStore.isLoaded && archivedProjects.isEmpty }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedProject) {
                Section("Projects") {
                    
                    if noProjects {
                        Text("No projects yet. Create one!")
                    }
                    
                    if isLoading {
                        LoaderView()
                    }
                    
                    ForEach(projects) { project in
                        NavigationLink(value: project.id) {
                            Text(project.name)
                                .fontWeight(.bold)
                        }
                    }
                }
                
                if !isLoading && !noArchivedProjects {
                    Section("Archived projects") {
                        ForEach(archivedProjects) { project in
                            NavigationLink(value: project.id) {
                                Text(project.name)
                                    .fontWeight(.bold)
                            }
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
        .toolbar {
            ToolbarItem(placement: .navigation) {
                HStack {
                    Image(systemName: "arrowtriangle.left")
                        .opacity(0.8)
                        .disabled(true)
                    Image(systemName: "arrowtriangle.right")
                        .opacity(0.8)
                        .disabled(true)
                }
            }
            
            ToolbarItem(placement: .secondaryAction) {
                if !currentTitle.isEmpty {
                    Text(currentTitle)
                        .font(.headline)
                }
            }
            
            if let currentProject = selectedProject {
                ToolbarItem(placement: .primaryAction) {
                    ProjectActionsView(projectId: currentProject) {
                        selectedProject = nil
                    }
                }
            }
        }
        .navigationTitle(currentTitle)
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
