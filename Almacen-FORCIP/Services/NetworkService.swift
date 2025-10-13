//
//  NetworkService.swift
//  Almacen-FORCIP
//
//  Created by Miguel Mexicano Herrera on 13/10/25.
//

import Foundation

// MARK: - Network Error
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case invalidResponse
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: Data?,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
}

// MARK: - Network Service Implementation
class NetworkService: NetworkServiceProtocol {
    
    static let shared = NetworkService()
    private let session = URLSession.shared
    private let baseURL = Constants.Api.baseUrl
    
    private init() {}
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
}
