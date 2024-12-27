//
//  AuthNetworkService.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/27/24.
//

import Foundation

struct AuthRequest: NetworkRequest {
    let username: String
    let password: String
}

struct AuthResponse: NetworkResponse {
    let token: String
}

struct AuthNetworkService {
    private let baseNetworkService: BaseNetworkService
    
    init(baseNetworkService: BaseNetworkService) {
        self.baseNetworkService = baseNetworkService
    }
    
    func login(username: String, password: String) async throws -> String {
        let request = AuthRequest(username: username, password: password)
        
        let response: AuthResponse = try await baseNetworkService.request(
            path: "/login",
            method: .post,
            body: request,
            expectedCode: 200)
        
        return response.token
    }
    
    func signup(username: String, password: String) async throws -> String {
        let request = AuthRequest(username: username, password: password)
        
        let response: AuthResponse = try await baseNetworkService.request(
            path: "/signup",
            method: .post,
            body: request,
            expectedCode: 201)
        
        return response.token
    }
}
