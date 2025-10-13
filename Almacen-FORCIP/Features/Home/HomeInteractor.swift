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

}

extension HomeInteractor: HomeRemoteDataManagerOutputProtocol {
    // TODO: Implement use case methods
}
