//
//  todo_list_macosApp.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/17/24.
//

import SwiftUI

@main
struct todo_list_macosApp: App {
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
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(router)
                .environmentObject(authStore)
                .environmentObject(projectStore)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
