//
//  HomeInteractor.swift
//  Almacen-FORCIP
//
//  Created by Miguel Mexicano Herrera on 13/10/25.
//
//

import Foundation

class HomeInteractor: HomeInteractorInputProtocol {

    // MARK: Properties
    weak var presenter: HomeInteractorOutputProtocol?
    var remoteDatamanager: HomeRemoteDataManagerInputProtocol?

    // MARK: - HomeInteractorInputProtocol
    func fetchProducts() {
        remoteDatamanager?.getProducts()
    }
    
    func sendQRCode(_ qrCode: String) {
        let requestBody = QRCodeRequestBody(lote: "48", observaciones: "ty")
        let request = QRCodeRequest.init(code: qrCode, tipo: "algo", fuente: "iOS", datos: requestBody)
        remoteDatamanager?.postQRCode(request)
    }
}

extension HomeInteractor: HomeRemoteDataManagerOutputProtocol {
    
    func onProductsReceived(_ products: [Product]) {
        presenter?.didLoadProducts(products)
    }
    
    func onError(_ error: String) {
        presenter?.didFailWithError(error)
    }
    
    func onQRCodeProcessed(_ response: QRCodeResponse) {
        presenter?.didProcessQRCode(response)
    }
    
    func onQRCodeError(_ error: String) {
        presenter?.didFailProcessingQRCode(error)
    }
}
