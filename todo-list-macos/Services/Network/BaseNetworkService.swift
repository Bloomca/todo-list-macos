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
struct EmptyResponse: NetworkResponse {}

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
    case emptyResponseData
}

struct HealthResponse: NetworkResponse {
    let status: String
}

extension URL {
    func appendingQueryParameters(_ parameters: [String: Any]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        let queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: String(describing: value))
        }
        // Append to existing query items if any
        if components.queryItems == nil {
            components.queryItems = queryItems
        } else {
            components.queryItems?.append(contentsOf: queryItems)
        }
        return components.url!
    }
}

class BaseNetworkService {
    let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func request<T: NetworkRequest, Response: NetworkResponse>(
        path: String,
        queryParameters: [String: Any] = [:],
        method: NetworkMethod,
        body: T?,
        expectedCode: Int,
        token: String? = nil
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path).appendingQueryParameters(queryParameters))
        request.httpMethod = method.rawValue
        
        if body != nil {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                request.httpBody = try encoder.encode(body)
            }
        }
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        print("Making a request to \(request.url!.absoluteString) with method \(method.rawValue)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("Received response with status \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == expectedCode else {
            throw NetworkError.unexpectedStatusCode(httpResponse.statusCode)
        }
        
        if Response.self is EmptyResponse.Type {
            // If it's an empty response type, just return it
            return EmptyResponse() as! Response
        }
        
        guard !data.isEmpty else {
            // If data is empty but we expected a response, throw an error
            // Unless the response type is EmptyResponse
            throw NetworkError.emptyResponseData
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
