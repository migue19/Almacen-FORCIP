//
//  HomeView.swift
//  Almacen-FORCIP
//
//  Created by Miguel Mexicano Herrera on 13/10/25.
//  
//

import Foundation
import UIKit

class HomeView: UIViewController {

    // MARK: Properties
    var presenter: HomePresenterProtocol?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension HomeView: HomeViewProtocol {
    // TODO: implement view output methods
}
