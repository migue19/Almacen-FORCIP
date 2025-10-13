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
    
    func viewDidLoad() {
        loadProducts()
    }
    
    func loadProducts() {
        view?.showLoading()
        interactor?.fetchProducts()
    }
    
    func refreshProducts() {
        loadProducts()
    }
}

extension HomePresenter: HomeInteractorOutputProtocol {
    
    func didLoadProducts(_ products: [Product]) {
        view?.hideLoading()
        view?.showProducts(products)
    }
    
    func didFailWithError(_ error: String) {
        view?.hideLoading()
        view?.showError(error)
    }
}
