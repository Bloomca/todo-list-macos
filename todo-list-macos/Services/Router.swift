//
//  Router.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import Foundation

enum RouterPath {
    case login
    case signup
    case app
}

@MainActor
class Router: ObservableObject {
    @Published var path: RouterPath

    init() {
        path = .login
    }
    
    func navigate(to path: RouterPath) {
        self.path = path
    }
}
