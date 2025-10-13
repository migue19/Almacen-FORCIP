//
//  HomeRemoteDataManager.swift
//  Almacen-FORCIP
//
//  Created by Miguel Mexicano Herrera on 13/10/25.
//
//

import Foundation

class HomeRemoteDataManager: HomeRemoteDataManagerInputProtocol {
    
    var remoteRequestHandler: HomeRemoteDataManagerOutputProtocol?
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    // MARK: - HomeRemoteDataManagerInputProtocol
    func getProducts() {
        networkService.request(
            endpoint: "/api/products",
            method: .GET,
            body: nil,
            responseType: ProductsResponse.self
        ) { [weak self] result in
            switch result {
            case .success(let response):
                self?.remoteRequestHandler?.onProductsReceived(response.products)
            case .failure(let error):
                let errorMessage = self?.getErrorMessage(from: error) ?? "Error desconocido"
                self?.remoteRequestHandler?.onError(errorMessage)
            }
        }
    }
    
    // MARK: - Private Methods
    private func getErrorMessage(from error: NetworkError) -> String {
        switch error {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos"
        case .decodingError:
            return "Error al procesar los datos"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        }
    }
}
