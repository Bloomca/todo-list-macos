//
//  BaseNetworkService.swift
//  todo-list-macos
//
//  Created by Vsevolod Zaikov on 12/27/24.
//

import Foundation

protocol NetworkRequest: Encodable {}
protocol NetworkResponse: Decodable {}

// This will make arrays of decodable items decodable as well
extension Array: NetworkResponse where Element: NetworkResponse {}

struct EmptyBody: NetworkRequest {}

enum NetworkMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case invalidResponse
    case unexpectedStatusCode(Int)
    case decodingError(Error)
}

struct HealthResponse: NetworkResponse {
    let status: String
}

class BaseNetworkService {
    let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func request<T: NetworkRequest, Response: NetworkResponse>(
        path: String,
        method: NetworkMethod,
        body: T?,
        expectedCode: Int,
        token: String? = nil
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        
        if body != nil {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONEncoder().encode(body)
            }
        }
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == expectedCode else {
            throw NetworkError.unexpectedStatusCode(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(Response.self, from: data)
    }
    
    // can be useful for debugging
    func checkHealth() async throws -> HealthResponse {
        let response: HealthResponse = try await request(path: "health",
                                                         method: .get,
                                                         body: nil as EmptyBody?,
                                                         expectedCode: 200)
        
        return response
    }
}
