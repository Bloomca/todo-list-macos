//
//  CustomIconButtonStyle.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/29/24.
//

import SwiftUI

struct CustomIconButtonStyle: ButtonStyle {
    @State private var isHovered = false
    
    let backgroundColor: Color
    let pressedOpacity: Double
    let scale: Double
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    init(
        backgroundColor: Color = .gray.opacity(0.1),
        pressedOpacity: Double = 0.7,
        scale: Double = 0.9,
        cornerRadius: CGFloat = 6,
        padding: CGFloat = 6
    ) {
        self.backgroundColor = backgroundColor
        self.pressedOpacity = pressedOpacity
        self.scale = scale
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .opacity(isHovered ? 1: 0)
                    .padding(-padding + 2)
            )
            .onHover { hovering in
                isHovered = hovering
            }
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
