//
//  HomePresenter.swift
//  Almacen-FORCIP
//
//  Created by Miguel Mexicano Herrera on 13/10/25.
//
//

import Foundation

class HomePresenter  {
    
    // MARK: Properties
    weak var view: HomeViewProtocol?
    var interactor: HomeInteractorInputProtocol?
    var router: HomeRouterProtocol?
    
}

extension HomePresenter: HomePresenterProtocol {
    func decodeQRCode(_ qrCode: String) {
        view?.showLoading()
        interactor?.decodeQRCode(qrCode)
    }
}

extension HomePresenter: HomeInteractorOutputProtocol {
    
    func didFailWithError(_ error: String) {
        view?.hideLoading()
        view?.showError(error)
    }
    
    func didProcessQRCode(_ response: QRCodeResponse) {
        view?.hideLoading()
        view?.showQRCodeResult(response)
    }
    
    func didFailProcessingQRCode(_ error: String) {
        view?.hideLoading()
        view?.showError(error)
    }

    func didDecodeOrdenCompra(_ orden: OrdenCompra) {
        view?.hideLoading()
        interactor?.sendOrdenCompra(orden)
    }

    func didFailDecodingQRCode(_ error: String) {
        view?.hideLoading()
        view?.showError(error)
    }
}
