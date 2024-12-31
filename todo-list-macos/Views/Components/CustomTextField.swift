//
//  CustomTextField.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/30/24.
//

import SwiftUI

struct CustomTextField: ViewModifier {
    @FocusState private var isFocused: Bool
    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.background)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isFocused ? .blue : .gray, lineWidth: 1)
            )
            .textFieldStyle(.plain)
    }
}
