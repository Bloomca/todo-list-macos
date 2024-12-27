//
//  MainView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import SwiftUI

struct MainView: View {
    @StateObject private var router: Router
    @StateObject private var authStore: AuthStore
    @StateObject private var projectStore: ProjectStore
    
    init() {
        let authStore = AuthStore()
        _router = StateObject(wrappedValue: Router())
        _authStore = StateObject(wrappedValue: authStore)
        _projectStore = StateObject(wrappedValue: ProjectStore(
            authStore: authStore
        ))
    }

    var body: some View {
        ContentView()
            .environmentObject(router)
            .environmentObject(authStore)
            .environmentObject(projectStore)
    }
}

#Preview {
    MainView()
}
