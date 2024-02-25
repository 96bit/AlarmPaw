//
//  SFSafariViewController.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/16.
//

import SafariServices
import UIKit
import SwiftUI



class PawSFSafariViewController: SFSafariViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    
}



struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        let sfVC =  SFSafariViewController(url: url)
//        sfVC.preferredBarTintColor = .blue // set color to tint the background of the navigation bar and the toolbar.
//        sfVC.preferredControlTintColor = .yellow // set the color to tint the control buttons on the navigation bar and the toolbar.
        
        return sfVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {
        return
    }

}

