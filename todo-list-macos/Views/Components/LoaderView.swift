//
//  LoaderView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/27/24.
//

import SwiftUI

enum LoaderStyle {
    case circular
    case dots
    case pulse
}

struct LoaderView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: "rays")
            .font(.system(size: 24, weight: .bold))
            .scaleEffect(isAnimating ? 1.2 : 0.8)
            .opacity(isAnimating ? 1 : 0.5)
            .animation(
                Animation.easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

#Preview {
    VStack(spacing: 40) {
        LoaderView()
    }
}
