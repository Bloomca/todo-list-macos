//
//  SectionView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/28/24.
//

import SwiftUI

struct SectionView: View {
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var sectionStore: SectionStore
    
    @State private var isCollapsed: Bool = false
    
    let section: SectionEntity
    
    var tasks: [TaskEntity] { taskStore.tasks.filter { $0.sectionId == section.id } }
    
    var body: some View {
        LazyVStack(spacing: 0) {
            HStack {
                Button {
                    isCollapsed.toggle()
                } label: {
                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                }
                .buttonStyle(CustomIconButtonStyle())
                .frame(width: 24, height: 24)
                Text(section.name)
                    .font(.headline)
                    .underline()
                Spacer()
            }
            .padding(.leading, 4)
            
            if !isCollapsed {
                ForEach(tasks) { task in
                    TaskView(task: task)
                    
                    Divider()
                }
                
                if section.archivedAt == nil {
                    InlineTaskEditor(projectId: section.projectId, sectionId: section.id)
                        .padding(.bottom, 8)
                }
                
            }
            
            if section.archivedAt == nil {
                InlineSectionEditor(projectId: section.projectId)
            }
        }
    }
}
