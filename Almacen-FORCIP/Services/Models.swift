//
//  Models.swift
//  Almacen-FORCIP
//
//  Created by Miguel Mexicano Herrera on 13/10/25.
//

import Foundation

struct QRCodeResponse: Codable {
    let status: String
    let message: String
    let idOrdenCompra: Int
}

// MARK: - Orden de Compra Model
struct OrdenCompra: Codable {
    let idOrdenCompra: Int
    let insumo: String
    let proveedor: String
    let fechaHora: String
    let pesoKg: Double?
    let pesoTarima: Double?

    enum CodingKeys: String, CodingKey {
        case idOrdenCompra = "idOrdenCompra"
        case insumo, proveedor
        case fechaHora = "fecha_hora"
        case pesoKg = "peso_kg"
        case pesoTarima = "peso_tarima"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // idOrdenCompra puede venir como Int o String
        if let intVal = try? c.decode(Int.self, forKey: .idOrdenCompra) {
            idOrdenCompra = intVal
        } else if let strVal = try? c.decode(String.self, forKey: .idOrdenCompra), let intVal = Int(strVal) {
            idOrdenCompra = intVal
        } else {
            idOrdenCompra = 0
        }

        insumo = (try? c.decode(String.self, forKey: .insumo)) ?? ""
        proveedor = (try? c.decode(String.self, forKey: .proveedor)) ?? ""
        fechaHora = (try? c.decode(String.self, forKey: .fechaHora)) ?? ""

        pesoKg = OrdenCompra.decodeDouble(from: c, key: .pesoKg)
        pesoTarima = OrdenCompra.decodeDouble(from: c, key: .pesoTarima)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(String(idOrdenCompra), forKey: .idOrdenCompra)
        try c.encode(insumo, forKey: .insumo)
        try c.encode(proveedor, forKey: .proveedor)
        try c.encode(fechaHora, forKey: .fechaHora)

        if let p = pesoKg {
            try c.encode(String(format: "%.2f", p), forKey: .pesoKg)
        } else {
            try c.encode("", forKey: .pesoKg)
        }

        if let p = pesoTarima {
            // usa formato sin decimales innecesarios
            try c.encode(String(format: "%g", p), forKey: .pesoTarima)
        } else {
            try c.encode("", forKey: .pesoTarima)
        }
    }

    private static func decodeDouble(from container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> Double? {
        if let d = try? container.decode(Double.self, forKey: key) {
            return d
        }
        if let str = try? container.decode(String.self, forKey: key) {
            let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { return nil }
            // reemplaza coma por punto por si viene con separador decimal local
            return Double(trimmed.replacingOccurrences(of: ",", with: "."))
        }
        return nil
    }
}
