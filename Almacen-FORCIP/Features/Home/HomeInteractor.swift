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
    func decodeQRCode(_ qrCode: String) {
        let trimmed = qrCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            presenter?.didFailDecodingQRCode("Código vacío")
            return
        }

        // Helper: intentar decodificar Data -> OrdenCompra
        func tryDecodeOrden(from data: Data) -> OrdenCompra? {
            let decoder = JSONDecoder()
            do {
                let orden = try decoder.decode(OrdenCompra.self, from: data)
                return orden
            } catch {
                return nil
            }
        }

        // 1) Intentar JSON directo
        if let data = trimmed.data(using: .utf8), let orden = tryDecodeOrden(from: data) {
            presenter?.didDecodeOrdenCompra(orden)
            return
        }

        // 2) Intentar Base64 -> JSON
        if let bData = Data(base64Encoded: trimmed), let orden = tryDecodeOrden(from: bData) {
            presenter?.didDecodeOrdenCompra(orden)
            return
        }

        // 3) Intentar cadena con query params (ej: idOrdenCompra=24&insumo=...)
        if trimmed.contains("=") && trimmed.contains("&") {
            var dict = [String: String]()
            let parts = trimmed.split(separator: "&")
            for part in parts {
                let kv = part.split(separator: "=", maxSplits: 1)
                if kv.count == 2 {
                    let key = String(kv[0]).removingPercentEncoding ?? String(kv[0])
                    let value = String(kv[1]).removingPercentEncoding ?? String(kv[1])
                    dict[key] = value
                }
            }
            if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) , let orden = tryDecodeOrden(from: jsonData) {
                presenter?.didDecodeOrdenCompra(orden)
                return
            }
        }

        // 4) Intentar pares clave:valor separados por comas, punto y coma o nuevas líneas
        if trimmed.contains(":") {
            var dict = [String: String]()
            let entries = trimmed.components(separatedBy: CharacterSet(charactersIn: ",;\n"))
            for entry in entries {
                let pair = entry.split(separator: ":", maxSplits: 1)
                if pair.count == 2 {
                    let key = pair[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let value = pair[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    dict[key] = value
                }
            }
            if !dict.isEmpty {
                // Mapear claves amigables a las claves reales del modelo si es necesario
                var mapped = [String: String]()
                for (k,v) in dict {
                    let lower = k.lowercased()
                    if lower.contains("id") && lower.contains("orden") { mapped["idOrdenCompra"] = v }
                    else if lower.contains("insumo") { mapped["insumo"] = v }
                    else if lower.contains("proveedor") { mapped["proveedor"] = v }
                    else if lower.contains("fecha") { mapped["fecha_hora"] = v }
                    else if lower.contains("peso") && lower.contains("kg") { mapped["peso_kg"] = v }
                    else if lower.contains("tarima") { mapped["peso_tarima"] = v }
                    else { mapped[k] = v }
                }
                if let jsonData = try? JSONSerialization.data(withJSONObject: mapped, options: []), let orden = tryDecodeOrden(from: jsonData) {
                    presenter?.didDecodeOrdenCompra(orden)
                    return
                }
            }
        }

        // 5) Si es sólo un número, interpretarlo como idOrdenCompra
        let digitsSet = CharacterSet.decimalDigits
        let trimmedDigits = trimmed.trimmingCharacters(in: digitsSet.inverted)
        if !trimmedDigits.isEmpty && trimmedDigits == trimmed {
            let dict: [String: String] = ["idOrdenCompra": trimmed, "insumo": "", "proveedor": "", "fecha_hora": "", "peso_kg": "", "peso_tarima": ""]
            if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []), let orden = tryDecodeOrden(from: jsonData) {
                presenter?.didDecodeOrdenCompra(orden)
                return
            }
        }
        // Si todo falla
        presenter?.didFailDecodingQRCode("No se pudo decodificar el código QR")
    }
    func sendOrdenCompra(_ orden: OrdenCompra) {
        remoteDatamanager?.postQRCode(orden)
    }
}

extension HomeInteractor: HomeRemoteDataManagerOutputProtocol {
    
    func onError(_ error: String) {
        presenter?.didFailWithError(error)
    }
    
    func onQRCodeProcessed(_ response: QRCodeResponse) {
        presenter?.didProcessQRCode(response)
    }
    
    func onQRCodeError(_ error: String) {
        presenter?.didFailProcessingQRCode(error)
    }
}
