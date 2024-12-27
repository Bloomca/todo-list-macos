//
//  AuthStore.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import Foundation

enum AuthError: Error {
    case tokenNotAvailable
}

class AuthStore: ObservableObject {
    @Published private var token: String?
    
    func setToken(_ token: String) {
        self.token = token
    }
    
    func getToken() throws -> String {
        guard let token = token else {
            throw AuthError.tokenNotAvailable
        }
        return token
    }
}
