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
    case serverError(message: String, statusCode: Int)
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
                
                if let json = try? JSONSerialization.jsonObject(with: data ?? Data()) {
                    print("Response JSON: \(json)")
                }
                
                // Verificar respuesta HTTP y manejar errores del servidor (p.ej. 400)
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    guard 200...299 ~= httpResponse.statusCode else {
                        // intentar extraer mensaje de error desde el body
                        var serverMessage = "Respuesta inválida del servidor"
                        if let data = data {
                            // Primero intentar decodificar como { "message": "...", "status": "error" }
                            if let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let msg = dict["message"] as? String {
                                serverMessage = msg
                            } else if let decoded = try? JSONDecoder().decode([String: String].self, from: data), let msg = decoded["message"] {
                                serverMessage = msg
                            }
                        }
                        completion(.failure(.serverError(message: serverMessage, statusCode: httpResponse.statusCode)))
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
                        print("Decoding error: \(error)")
                        completion(.failure(.decodingError))
                    }
                } else {
                    completion(.failure(.invalidResponse))
                    return
                }
            }
        }.resume()
    }
}
