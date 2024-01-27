//
//  NotificationViewController.swift
//  NotificationImageExtension
//
//  Created by He Cho on 2024/1/17.
//



import UIKit
import UserNotifications
import UserNotificationsUI


class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet var contentImage: UIImageView?
    @IBOutlet var content: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func didReceive(_ notification: UNNotification) {
        print(notification.request.content.userInfo)
        let userInfo = notification.request.content.userInfo

        guard let imageFileUrl = userInfo["imageFile"] as? String else { return }
        
        
        DispatchQueue.main.async {
            if let imageData = try? Data(contentsOf: URL(fileURLWithPath: imageFileUrl)),
               let image = UIImage(data: imageData) {
                // 将图像设置到 UIImageView 中
                self.contentImage?.image = image
                self.contentImage?.contentMode = .scaleAspectFill
            }
        }
        
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let copy = userInfo["copy"] as? String {
            UIPasteboard.general.string = copy
        }
        
        if response.actionIdentifier == "cancel"{
            completion(.dismiss)
        }else if response.actionIdentifier == "copy"{
            UIPasteboard.general.string = response.notification.request.content.body
            self.content.text = "复制成功"
           
            self.content.textColor = .red
            let labelSize = self.content.sizeThatFits(CGSize(width: self.view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
            self.content.frame.size = labelSize
                   
                   // 4. 设置UILabel的frame，使其居中
            self.content.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
                   
                   // 将UILabel添加到视图中
            self.view.addSubview(self.content)
            
            completion(.doNotDismiss)
        }else{
            completion(.doNotDismiss)
        }
    }
    
}
