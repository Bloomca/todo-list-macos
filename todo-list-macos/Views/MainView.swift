//
//  MainView.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import SwiftUI

struct MainView: View {
    @StateObject private var router: Router = Router()
    @StateObject private var authStore: AuthStore = AuthStore()
    @StateObject private var projectStore: ProjectStore = ProjectStore()

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
