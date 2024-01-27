//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by He Cho on 2024/1/16.
//



import UIKit
import UserNotifications
import UserNotificationsUI


class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    let contentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0) // 设置初始框架
        return imageView
    }()
    
    let content: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 0, height: 0) // 设置初始框架
        return label
    }()
    
    var viewHeight = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(content)
        self.view.addSubview(contentImage)
        
        self.preferredContentSize = CGSize(width: 0, height: 1)
    }
    
    
    func didReceive(_ notification: UNNotification) {
        print(notification.request.content.userInfo)
        let userInfo = notification.request.content.userInfo
        
        if let autoCopy = userInfo["autocopy"]as? String,autoCopy == "1" {
            if let copy = userInfo["copy"] as? String {
                UIPasteboard.general.string = copy
            }
            else {
                UIPasteboard.general.string = notification.request.content.body
            }
        }
        
        guard let imageFileUrl = userInfo["imageFile"] as? String else {
            self.contentImage.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let imageData = try? Data(contentsOf: URL(fileURLWithPath: imageFileUrl)),
               let image = UIImage(data: imageData) {
                
//                let fixedWidth: CGFloat = // 设置固定宽度
//                let imageWidth: CGFloat = // 图像的原始宽度
//                let imageHeight: CGFloat = // 图像的原始高度
//
//                // 计算高度以保持宽高比

                let fixedWidth: CGFloat = self.view.bounds.width
                let aspectRatio = image.size.width / image.size.height
                let calculatedHeight = fixedWidth / aspectRatio
                
                
                print(image.size,self.view.bounds)
                DispatchQueue.main.async {
                    self.contentImage.image = image
                    self.contentImage.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: calculatedHeight)
                    self.preferredContentSize = CGSize(width: self.view.bounds.width, height: calculatedHeight)
                }
            } else {
                DispatchQueue.main.async {
                    // 图像加载失败时的处理，如设置占位图或更新UI
                    self.contentImage.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                    self.preferredContentSize = CGSize(width: self.view.bounds.width, height: 1)
                }
            }
        }
        
        
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let copy = userInfo["copy"] as? String {
            UIPasteboard.general.string = copy
        }
        else {
            UIPasteboard.general.string = response.notification.request.content.body
        }
        self.content.text = NSLocalizedString("groupMessageMode", comment: "复制成功")
        completion(.dismiss)
    }
    
}

