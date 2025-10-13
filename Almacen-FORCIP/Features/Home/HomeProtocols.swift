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
}
// INTERACTOR -> PRESENTER
protocol HomeInteractorOutputProtocol: AnyObject {
}
// PRESENTER -> INTERACTOR
protocol HomeInteractorInputProtocol: AnyObject {
    var presenter: HomeInteractorOutputProtocol? { get set }
    var remoteDatamanager: HomeRemoteDataManagerInputProtocol? { get set }
}
// INTERACTOR -> DATAMANAGER
protocol HomeDataManagerInputProtocol: AnyObject {
}
// INTERACTOR -> REMOTEDATAMANAGER
protocol HomeRemoteDataManagerInputProtocol: AnyObject {
    var remoteRequestHandler: HomeRemoteDataManagerOutputProtocol? { get set }
}
// REMOTEDATAMANAGER -> INTERACTOR
protocol HomeRemoteDataManagerOutputProtocol: AnyObject {
}
