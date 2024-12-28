//
//  TaskView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/27/24.
//

import SwiftUI

struct TaskView: View {
    var task: TaskEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}
