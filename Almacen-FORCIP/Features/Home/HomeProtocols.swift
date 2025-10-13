//
//  HomeProtocols.swift
//  Almacen-FORCIP
//
//  Created by Miguel Mexicano Herrera on 13/10/25.
//
//

import Foundation
import UIKit
// PRESENTER -> VIEW
protocol HomeViewProtocol: AnyObject {
    var presenter: HomePresenterProtocol? { get set }
    
    func showProducts(_ products: [Product])
    func showError(_ message: String)
    func showLoading()
    func hideLoading()
    func showQRCodeResult(_ response: QRCodeResponse)
}
// PRESENTER -> ROUTER
protocol HomeRouterProtocol: AnyObject {
    var view: HomeView? { get set }
    static func createHomeModule() -> UIViewController
}
// VIEW -> PRESENTER
protocol HomePresenterProtocol: AnyObject {
    var view: HomeViewProtocol? { get set }
    var interactor: HomeInteractorInputProtocol? { get set }
    var router: HomeRouterProtocol? { get set }
    
    func viewDidLoad()
    func loadProducts()
    func refreshProducts()
    func processQRCode(_ qrCode: String)
}
// INTERACTOR -> PRESENTER
protocol HomeInteractorOutputProtocol: AnyObject {
    func didLoadProducts(_ products: [Product])
    func didFailWithError(_ error: String)
    func didProcessQRCode(_ response: QRCodeResponse)
    func didFailProcessingQRCode(_ error: String)
}
// PRESENTER -> INTERACTOR
protocol HomeInteractorInputProtocol: AnyObject {
    var presenter: HomeInteractorOutputProtocol? { get set }
    var remoteDatamanager: HomeRemoteDataManagerInputProtocol? { get set }
    
    func fetchProducts()
    func sendQRCode(_ qrCode: String)
}
// INTERACTOR -> DATAMANAGER
protocol HomeDataManagerInputProtocol: AnyObject {
}
// INTERACTOR -> REMOTEDATAMANAGER
protocol HomeRemoteDataManagerInputProtocol: AnyObject {
    var remoteRequestHandler: HomeRemoteDataManagerOutputProtocol? { get set }
    
    func getProducts()
    func postQRCode(_ request: QRCodeRequest)
}
// REMOTEDATAMANAGER -> INTERACTOR
protocol HomeRemoteDataManagerOutputProtocol: AnyObject {
    func onProductsReceived(_ products: [Product])
    func onError(_ error: String)
    func onQRCodeProcessed(_ response: QRCodeResponse)
    func onQRCodeError(_ error: String)
}
