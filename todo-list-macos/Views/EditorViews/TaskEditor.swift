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
        VStack(spacing: 8) {
            TextField("Task name", text: $taskName)
                .modifier(CustomTextField(shouldAutoFocus: true))
            TextField("Task description", text: $taskDescription)
                .modifier(CustomTextField())
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(InlineSecondaryButton())
                
                Button("Save") {
                    Task {
                        do {
                            isSaving = true
                            savingError = nil
                            try await taskStore.createTask(projectId: projectId,
                                                           sectionId: sectionId,
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
                .buttonStyle(InlinePrimaryButton())
            }
            .padding(.top, 4)
            
        }
        .padding(8)
        .background(.background)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct InlineTaskEditor: View {
    @State var isPresented: Bool = false
    
    var projectId: Int
    var sectionId: Int? = nil
    
    var body: some View {
        VStack {
            if isPresented {
                TaskEditor(isPresented: $isPresented, projectId: projectId, sectionId: sectionId)
            } else {
                Button {
                    isPresented = true
                } label: {
                    Label("Add new task", systemImage: "plus")
                }
            }
        }
        .padding(.top, 16)
    }
}

struct InlineSecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(configuration.isPressed ? .gray : .gray.opacity(0.9))
            .cornerRadius(6)
    }
}

struct InlinePrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(configuration.isPressed ?
                Color.blue.opacity(0.8) :
                Color.blue)
            .cornerRadius(6)
    }
}
