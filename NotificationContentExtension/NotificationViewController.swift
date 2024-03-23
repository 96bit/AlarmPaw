//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by He Cho on 2024/1/16.
//



import UIKit
import UserNotifications
import UserNotificationsUI
import WebKit
import Down


class NotificationViewController: UIViewController, UNNotificationContentExtension {
    let webview:WKWebView = {
        let web = WKWebView()
        return web
    }()
    
    let copyTips: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 0, height: 0) // 设置初始框架
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(copyTips)
        self.view.addSubview(webview)
        
        webview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webview.topAnchor.constraint(equalTo: view.topAnchor),
            webview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    
    func didReceive(_ notification: UNNotification) {
        
        let userInfo = notification.request.content.userInfo
        
        if let autoCopy = userInfo["autocopy"]as? String,autoCopy == "1" {
            if let copy = userInfo["copy"] as? String {
                UIPasteboard.general.string = copy
            }
            else {
                UIPasteboard.general.string = notification.request.content.body
            }
        }
        
        if let markdown = userInfo["markdown"] as? String {
            
            let down = Down(markdownString: markdown)
            if let html = try? down.toHTML(){
                webview.loadHTMLString(html, baseURL: nil)
                return
            }
            
        }
        self.preferredContentSize = CGSize(width: 0, height: 1)
        webview.removeFromSuperview()
       
        
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let copy = userInfo["copy"] as? String {
            UIPasteboard.general.string = copy
        }
        else {
            UIPasteboard.general.string = response.notification.request.content.body
        }
        self.copyTips.text = NSLocalizedString("groupMessageMode", comment: "复制成功")
        self.copyTips.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 10)
        completion(.dismiss)
    }
    
    

    
}

