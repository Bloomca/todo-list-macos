//
//  SectionEditor.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/28/24.
//

import SwiftUI

struct SectionEditor: View {
    @EnvironmentObject var sectionStore: SectionStore
    
    @Binding var isPresented: Bool
    
    var projectId: Int
    
    @State var sectionName: String = ""
    @State var isSaving: Bool = false
    @State var savingError: Error? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            TextField("Section name", text: $sectionName)
                .modifier(CustomTextField())
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(InlineSecondaryButton())
                
                Button("Save") {
                    Task {
                        do {
                            isSaving = true
                            savingError = nil
                            try await sectionStore.createSection(projectId: projectId, name: sectionName)
                            isSaving = false
                            isPresented = false
                        } catch {
                            isSaving = false
                            savingError = error
                        }
                    }
                }
                .disabled(isSaving || sectionName.isEmpty)
                .buttonStyle(InlinePrimaryButton())
            }
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

struct InlineSectionEditor: View {
    @State private var isPresented: Bool = false
    @State private var isHovered = false
    
    var projectId: Int
    
    var body: some View {
        VStack {
            if isPresented {
                SectionEditor(isPresented: $isPresented, projectId: projectId)
            } else {
                Button {
                    isPresented = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add section")
                    }
                }
                .opacity(isHovered ? 1 : 0)
                .onHover { hovering in
                    withAnimation {
                        isHovered = hovering
                    }
                }
                .frame(width: 500)
            }
        }
    }
}
