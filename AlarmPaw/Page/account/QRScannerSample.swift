//
//  QRScannerSample.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/2/25.
//

import QRScanner // If use the Pod way, please import MercariQRScanner
import AVFoundation
import UIKit

final class QRScannerViewController: UIViewController {
    var QRView:QRScannerView?
    var flash: Bool = false
    var valueChange:((String)-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRScanner()
    }

    private func setupQRScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupQRScannerView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { [weak self] in
                        self?.setupQRScannerView()
                    }
                }
            }
        default:
            showAlert()
        }
    }

    private func setupQRScannerView() {
        self.QRView = QRScannerView(frame: view.bounds)
        view.addSubview(self.QRView!)
        self.QRView?.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        self.QRView?.startRunning()
    }

    private func showAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let alert = UIAlertController(title: "Error", message: "Camera is required to use in this application", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    
    func toggleTorch(on: Bool) {
           guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }

           do {
               try device.lockForConfiguration()

               device.torchMode = on ? .on : .off

               device.unlockForConfiguration()
           } catch {
               print("Torch could not be used")
           }
       }
}

extension QRScannerViewController: QRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(error)
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        self.valueChange?(code)
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didChangeTorchActive isOn: Bool) {
        self.toggleTorch(on: isOn)
    }
}


final class FlashButton: UIButton {
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        settings()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        settings()
    }

    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            let color: UIColor = isSelected ? .gray : .lightGray
            backgroundColor = color.withAlphaComponent(0.7)
        }
    }
}

// MARK: - Private
private extension FlashButton {
    func settings() {
        setTitleColor(.darkGray, for: .normal)
        setTitleColor(.white, for: .selected)
        setTitle("OFF", for: .normal)
        setTitle("ON", for: .selected)
        tintColor = .clear
        titleLabel?.font = .boldSystemFont(ofSize: 16)
        layer.cornerRadius = frame.size.width / 2
        isSelected = false
    }
}
