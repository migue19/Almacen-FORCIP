//
//  HomeView.swift
//  Almacen-FORCIP
//
//  Created by Miguel Mexicano Herrera on 13/10/25.
//
//

import Foundation
import UIKit
import AVFoundation

class HomeView: UIViewController {

    // MARK: Properties
    var presenter: HomePresenterProtocol?
    
    // QR Scanner Properties
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var scannerView: UIView!
    private var isScanning = false
    
    // UI Elements
    private let scanQRButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Escanear QR", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false && isScanning {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    // MARK: UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Almacén FORCIP"
        
        view.addSubview(scanQRButton)
        scanQRButton.addTarget(self, action: #selector(scanQRButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scanQRButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanQRButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanQRButton.widthAnchor.constraint(equalToConstant: 200),
            scanQRButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: QR Scanner Methods
    
    @objc private func scanQRButtonTapped() {
        checkCameraPermissions()
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startQRScanner()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.startQRScanner()
                    } else {
                        self?.showPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            showPermissionAlert()
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Permisos de Cámara",
            message: "Para escanear códigos QR, necesitamos acceso a la cámara. Por favor, permite el acceso en Configuración.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Configuración", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func startQRScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showScanError("No se pudo acceder a la cámara")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showScanError("Error al configurar la cámara")
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            showScanError("No se pudo configurar la entrada de video")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]
        } else {
            showScanError("No se pudo configurar la salida de metadatos")
            return
        }
        
        setupScannerView()
    }
    
    private func setupScannerView() {
        scannerView = UIView()
        scannerView.backgroundColor = .black
        scannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scannerView)
        
        NSLayoutConstraint.activate([
            scannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scannerView.layer.addSublayer(previewLayer)
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Cerrar", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        closeButton.layer.cornerRadius = 8
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeScannerTapped), for: .touchUpInside)
        
        scannerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: scannerView.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: scannerView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 80),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Add scanning indicator
        let scanLabel = UILabel()
        scanLabel.text = "Apunta la cámara hacia un código QR"
        scanLabel.textColor = .white
        scanLabel.textAlignment = .center
        scanLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        scanLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        scanLabel.layer.cornerRadius = 8
        scanLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scannerView.addSubview(scanLabel)
        
        NSLayoutConstraint.activate([
            scanLabel.bottomAnchor.constraint(equalTo: scannerView.bottomAnchor, constant: -50),
            scanLabel.centerXAnchor.constraint(equalTo: scannerView.centerXAnchor),
            scanLabel.widthAnchor.constraint(equalToConstant: 280),
            scanLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        isScanning = true
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    @objc private func closeScannerTapped() {
        stopScanning()
    }
    
    private func stopScanning() {
        if captureSession?.isRunning == true {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.stopRunning()
            }
        }
        
        scannerView?.removeFromSuperview()
        scannerView = nil
        previewLayer = nil
        captureSession = nil
        isScanning = false
    }
    
    private func showScanError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handleScannedCode(_ code: String) {
        // Detener el escaneo temporalmente para evitar múltiples lecturas
        captureSession.stopRunning()
        
        // Vibración de feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Mostrar el resultado
        let alert = UIAlertController(
            title: "Código QR Escaneado",
            message: "Contenido: \(code)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Escanear Otro", style: .default) { [weak self] _ in
            DispatchQueue.global(qos: .background).async {
                self?.captureSession.startRunning()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel) { [weak self] _ in
            self?.stopScanning()
        })
        
        present(alert, animated: true)
        
        // Aquí puedes agregar tu lógica personalizada para manejar el código escaneado
        // Por ejemplo: presenter?.handleScannedQRCode(code)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension HomeView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            handleScannedCode(stringValue)
        }
    }
}

extension HomeView: HomeViewProtocol {
    // TODO: implement view output methods
}
