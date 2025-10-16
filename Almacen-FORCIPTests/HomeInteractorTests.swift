import XCTest
@testable import Almacen_FORCIP

final class HomeInteractorTests: XCTestCase {

    class MockPresenter: HomeInteractorOutputProtocol {
        var decodedOrden: OrdenCompra?
        var decodeError: String?

        var loadedProducts: [Product]?
        var productError: String?
        var qrResponse: QRCodeResponse?
        var qrError: String?

        func didLoadProducts(_ products: [Product]) {
            loadedProducts = products
        }
        func didFailWithError(_ error: String) {
            productError = error
        }
        func didProcessQRCode(_ response: QRCodeResponse) {
            qrResponse = response
        }
        func didFailProcessingQRCode(_ error: String) {
            qrError = error
        }
        func didDecodeOrdenCompra(_ orden: OrdenCompra) {
            decodedOrden = orden
        }
        func didFailDecodingQRCode(_ error: String) {
            decodeError = error
        }
    }

    var interactor: HomeInteractor!
    var presenter: MockPresenter!

    override func setUp() {
        super.setUp()
        interactor = HomeInteractor()
        presenter = MockPresenter()
        interactor.presenter = presenter
    }

    override func tearDown() {
        interactor = nil
        presenter = nil
        super.tearDown()
    }

    func testDecodeJSONDirect() {
        let json = """
        {"idOrdenCompra":"24","insumo":"Seleccione un insumo","proveedor":"MIGUEL SOTO","fecha_hora":"15/10/2025, 11:59:32 a.m.","peso_kg":"0.00","peso_tarima":""}
        """
        interactor.decodeQRCode(json)
        XCTAssertNotNil(presenter.decodedOrden)
        XCTAssertEqual(presenter.decodedOrden?.idOrdenCompra, 24)
        XCTAssertEqual(presenter.decodedOrden?.insumo, "Seleccione un insumo")
        XCTAssertEqual(presenter.decodedOrden?.proveedor, "MIGUEL SOTO")
        XCTAssertEqual(presenter.decodedOrden?.fechaHora, "15/10/2025, 11:59:32 a.m.")
        XCTAssertEqual(presenter.decodedOrden?.pesoKg, 0.0)
        XCTAssertNil(presenter.decodedOrden?.pesoTarima)
    }

    func testDecodeBase64() {
        let json = "{" + "\"idOrdenCompra\":\"24\",\"insumo\":\"Seleccione un insumo\",\"proveedor\":\"MIGUEL SOTO\",\"fecha_hora\":\"15/10/2025, 11:59:32 a.m.\",\"peso_kg\":\"0.00\",\"peso_tarima\":\"\"}"
        let b64 = Data(json.utf8).base64EncodedString()
        interactor.decodeQRCode(b64)
        XCTAssertNotNil(presenter.decodedOrden)
        XCTAssertEqual(presenter.decodedOrden?.idOrdenCompra, 24)
    }

    func testDecodeQueryParams() {
        let query = "idOrdenCompra=24&insumo=Seleccione%20un%20insumo&proveedor=MIGUEL%20SOTO&fecha_hora=15/10/2025, 11:59:32 a.m.&peso_kg=0.00&peso_tarima="
        interactor.decodeQRCode(query)
        XCTAssertNotNil(presenter.decodedOrden)
        XCTAssertEqual(presenter.decodedOrden?.idOrdenCompra, 24)
    }

    func testDecodeKeyValuePairs() {
        let kv = "idOrdenCompra:24,insumo:Seleccione un insumo,proveedor:MIGUEL SOTO,fecha_hora:15/10/2025, 11:59:32 a.m.,peso_kg:0.00,peso_tarima:"
        interactor.decodeQRCode(kv)
        XCTAssertNotNil(presenter.decodedOrden)
        XCTAssertEqual(presenter.decodedOrden?.idOrdenCompra, 24)
    }

    func testDecodeOnlyNumber() {
        interactor.decodeQRCode("24")
        XCTAssertNotNil(presenter.decodedOrden)
        XCTAssertEqual(presenter.decodedOrden?.idOrdenCompra, 24)
    }
}
