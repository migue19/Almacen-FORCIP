//
//  Models.swift
//  Almacen-FORCIP
//
//  Created by Miguel Mexicano Herrera on 13/10/25.
//

import Foundation

// MARK: - QR Code Models
struct QRCodeRequest: Codable {
    let code: String
    let tipo: String
    let fuente: String
    let datos: QRCodeRequestBody

    enum CodingKeys: String, CodingKey {
        case code = "codigo"
        case tipo, fuente, datos
    }
}
struct QRCodeRequestBody: Codable {
    let lote: String
    let observaciones: String
}

struct QRCodeResponse: Codable {
    let status: String
    let message: String
    let codigo: String
}

// MARK: - Product Model
struct Product: Codable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let stock: Int
    let category: String
    let imageUrl: String?
    let sku: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, price, stock, category, sku
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Products Response
struct ProductsResponse: Codable {
    let products: [Product]
    let totalCount: Int
    let page: Int
    let limit: Int
    
    enum CodingKeys: String, CodingKey {
        case products
        case totalCount = "total_count"
        case page, limit
    }
}

// MARK: - Category Model
struct Category: Codable {
    let id: Int
    let name: String
    let description: String?
    let productCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case productCount = "product_count"
    }
}

// MARK: - Inventory Movement
struct InventoryMovement: Codable {
    let id: Int
    let productId: Int
    let type: MovementType
    let quantity: Int
    let reason: String
    let userId: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case type, quantity, reason
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

enum MovementType: String, Codable {
    case entrada = "entrada"
    case salida = "salida"
    case ajuste = "ajuste"
}
