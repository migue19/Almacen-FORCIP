//
//  HomeRouter.swift
//  Almacen-FORCIP
//
//  Created by Miguel Mexicano Herrera on 13/10/25.
//  
//

import Foundation
import UIKit

class HomeRouter: HomeRouterProtocol {
    weak var view: HomeView?
    
    class func createHomeModule() -> UIViewController {
        let view = HomeView()
        let presenter: HomePresenterProtocol & HomeInteractorOutputProtocol = HomePresenter()
        let interactor: HomeInteractorInputProtocol & HomeRemoteDataManagerOutputProtocol = HomeInteractor()
        let remoteDataManager: HomeRemoteDataManagerInputProtocol = HomeRemoteDataManager()
        let router: HomeRouterProtocol = HomeRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        interactor.remoteDatamanager = remoteDataManager
        remoteDataManager.remoteRequestHandler = interactor
        router.view = view
        
        return view
    }
}
