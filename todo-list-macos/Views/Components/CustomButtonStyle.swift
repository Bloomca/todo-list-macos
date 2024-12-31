//
//  CustomButtonStyle.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/30/24.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 80)
            .padding(8)
            .cornerRadius(8)
    }
}
