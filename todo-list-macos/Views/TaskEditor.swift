//
//  TaskEditor.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/27/24.
//

import SwiftUI

struct TaskEditor: View {
    @EnvironmentObject var taskStore: TaskStore
    
    @Binding var isPresented: Bool
    
    var projectId: Int
    var sectionId: Int? = nil
    
    @State var taskName: String = ""
    @State var taskDescription: String = ""
    @State var isSaving: Bool = false
    @State var savingError: Error? = nil
    
    var body: some View {
        VStack {
            TextField("Task name", text: $taskName)
                .textFieldStyle(.roundedBorder)
            TextField("Task description", text: $taskDescription)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                
                Button("Save") {
                    Task {
                        do {
                            isSaving = true
                            savingError = nil
                            try await taskStore.createTask(projectId: projectId,
                                                           name: taskName,
                                                           description: taskDescription)
                            isSaving = false
                            isPresented = false
                        } catch {
                            isSaving = false
                            savingError = error
                        }
                    }
                }
                .disabled(isSaving || taskName.isEmpty)
                .buttonStyle(.borderedProminent)
            }
            
        }
        .border(.brown)
    }
}

struct InlineTaskEditor: View {
    @State var isPresented: Bool = false
    
    var projectId: Int
    
    var body: some View {
        VStack {
            if isPresented {
                TaskEditor(isPresented: $isPresented, projectId: projectId)
            } else {
                Button {
                    isPresented = true
                } label: {
                    Label("Add new task", systemImage: "plus")
                }
            }
        }
    }
}
