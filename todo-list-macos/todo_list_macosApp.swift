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
    @StateObject private var taskStore: TaskStore
    @StateObject private var sectionStore: SectionStore
    
    init() {
        let authStore = AuthStore()
        _router = StateObject(wrappedValue: Router())
        _authStore = StateObject(wrappedValue: authStore)
        _projectStore = StateObject(wrappedValue: ProjectStore(authStore: authStore))
        _taskStore = StateObject(wrappedValue: TaskStore(authStore: authStore))
        _sectionStore = StateObject(wrappedValue: SectionStore(authStore: authStore))
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(router)
                .environmentObject(authStore)
                .environmentObject(projectStore)
                .environmentObject(taskStore)
                .environmentObject(sectionStore)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
