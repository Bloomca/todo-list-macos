//
//  FetchService.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/26/24.
//

import Foundation

struct AuthRequest: Encodable {
    let username: String
    let password: String
}

struct AuthResponse: Decodable {
    let token: String
}

struct CreateProjectRequest: Encodable {
    let name: String
    let description: String
}

struct FetchService {
    let baseURL = URL(string: "https://todo-list-api.bloomca.me")!
    
    func login(username: String, password: String) async throws -> String {
        return try await authenticate(username: username,
                                       password: password,
                                       endpoint: "login",
                                       expectedCode: 200)
    }
        
    func signup(username: String, password: String) async throws -> String {
        return try await authenticate(username: username,
                                   password: password,
                                   endpoint: "signup",
                                   expectedCode: 201)
    }
    
    private func authenticate(username: String, password: String, endpoint: String, expectedCode: Int) async throws -> String {
        let authURL = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: authURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = AuthRequest(username: username, password: password)
        let jsonData = try JSONEncoder().encode(body)
        
        // Debug: print the request body
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Request body: \(jsonString)")
        }
        
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Debug: print the response
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response data: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == expectedCode else {
            throw URLError(.badURL)
        }
        
        let result = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        return result.token
    }
    
    func checkHealth() async throws {
        let healthURL = baseURL.appendingPathComponent("health")
        
        var request = URLRequest(url: healthURL)
        request.httpMethod = "GET"
        
        print("Attempting to connect to: \(healthURL)")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Not an HTTP response")
            throw URLError(.badServerResponse)
        }
        
        print("Got response with status code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            print("Unexpected status code: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
    }
    
    func createProject(token: String, name: String, description: String) async throws -> Project {
        let createProjectURL = baseURL.appendingPathComponent("projects")
        
        var request = URLRequest(url: createProjectURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body = CreateProjectRequest(name: name, description: description)
        request.httpBody = try JSONEncoder().encode(body)
     
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 201 else {
            throw URLError(.badURL)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(Project.self, from: data)
    }
    
    func getProjects(token: String) async throws -> [Project] {
        let projectsURL = baseURL.appendingPathComponent("projects")
        var request = URLRequest(url: projectsURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badURL)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode([Project].self, from: data)
    }
}
