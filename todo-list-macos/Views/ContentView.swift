//
//  ContentView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/17/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            switch router.path {
            case .login:
                LoginView()
            case .signup:
                SignupView()
            case .app:
                AppView()
            }
        }
    }
}

#Preview {
    ContentView()
}
