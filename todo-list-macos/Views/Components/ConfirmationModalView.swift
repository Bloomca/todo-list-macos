//
//  ConfirmationModalView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/30/24.
//

import SwiftUI

struct ConfirmationModalView: View {
    let title: String
    let confirmTitle: String
    var description: String = ""
    var errorTitle: String? = nil
    let onCancel: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top, 8)
            
            if !description.isEmpty {
                Text(description)
                    .font(.subheadline)
            }
            
            if let errorTitle {
                Text(errorTitle)
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
            
            HStack(spacing: 12) {
                Button {
                    onCancel()
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
                    onConfirm()
                } label: {
                    Text(confirmTitle)
                        .frame(minWidth: 80)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(.teal)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)
        }
        .padding(12)
        .frame(width: 260)
        .background(.background)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 2)
    }
}
