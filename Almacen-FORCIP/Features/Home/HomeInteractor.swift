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
}

extension HomeInteractor: HomeRemoteDataManagerOutputProtocol {
    
    func onProductsReceived(_ products: [Product]) {
        presenter?.didLoadProducts(products)
    }
    
    func onError(_ error: String) {
        presenter?.didFailWithError(error)
    }
}
