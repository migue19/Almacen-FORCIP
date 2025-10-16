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
    func postQRCode(_ request: OrdenCompra) {
        do {
            let jsonData = try JSONEncoder().encode(request)
            networkService.request(
                endpoint: "/recibe_qr.php",
                method: .POST,
                body: jsonData,
                responseType: QRCodeResponse.self
            ) { [weak self] result in
                switch result {
                case .success(let response):
                    self?.remoteRequestHandler?.onQRCodeProcessed(response)
                case .failure(let error):
                    let errorMessage = self?.getErrorMessage(from: error) ?? "Error desconocido"
                    self?.remoteRequestHandler?.onQRCodeError(errorMessage)
                }
            }
        } catch {
            remoteRequestHandler?.onQRCodeError("Error al codificar la solicitud")
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
        case .serverError(let message, let statusCode):
            // Si el servidor devolvió un mensaje específico, devolverlo tal cual.
            // En particular maneja respuestas 400 como: "El parámetro \"codigo\" es requerido"
            if !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return message
            }
            return "Error del servidor (\(statusCode))"
        }
    }
}
