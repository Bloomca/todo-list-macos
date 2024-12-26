//
//  ContentView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/17/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var route: Router = Router()
    
    var body: some View {
        VStack {
            switch route.path {
            case .login:
                LoginView()
            case .signup:
                SignupView()
            case .app:
                AppView()
            }
        }
        .padding()
        .frame(width: 640, height: 480)
    }
}

#Preview {
    ContentView()
}
