//
//  QRView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/2/25.
//


import SwiftUI

struct QRScannerSampleView: UIViewControllerRepresentable {
    @Binding var restart:Bool
    @Binding var flash:Bool
    @Binding var value:String
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let qrview = QRScannerViewController()
        qrview.valueChange = changeValue
        return qrview
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        // Here you can update the controller if needed.
        if restart {
            uiViewController.QRView?.rescan()
            DispatchQueue.main.async{
                self.restart = false
            }
            
        }
        uiViewController.toggleTorch(on: flash)
        
    }
    
    func changeValue(_ value: String){
        self.value = value
    }
    
    func restartScan(_ value: Bool){
        if value{
            
        }
        
    }
}

