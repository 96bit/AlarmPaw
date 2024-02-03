//
//  AppDelegate.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/13.
//

import Foundation
import SwiftUI
import UserNotifications
import RealmSwift

struct Identifiers {
    static let reminderCategory = "myNotificationCategory"
    static let cancelAction = "cancel"
    static let copyAction = "copy"
}




class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate{
  
    let generator = UISelectionFeedbackGenerator()
    
    func setupRealm() {
        let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: settings.groupName.rawValue)
        let fileUrl = groupUrl?.appendingPathComponent(settings.realmName.rawValue)
        
        let config = Realm.Configuration(
            fileURL: fileUrl,
            schemaVersion: 2,
            migrationBlock: { _, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 1 {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            }
        )

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        #if DEBUG
            let realm = try? Realm()
            print("message count: \(realm?.objects(Message.self).count ?? 0)")
        #endif
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        // MARK: 将设备令牌发送到服务器
       
        pawManager.shared.dispatch_sync_safely_main_queue {
            pawManager.shared.deviceToken = token
        }
        
        Task(priority: .userInitiated) { 
            await  pawManager.shared.registerAll()
        }
        
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // MARK:  处理注册失败的情况
        debugPrint(error)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        
        // 必须在应用一开始就配置，否则应用可能提前在配置之前试用了 Realm() ，则会创建两个独立数据库。
        setupRealm()
        
        UNUserNotificationCenter.current().delegate = self
        
        
        let copyAction =  UNNotificationAction(identifier:Identifiers.copyAction, title: NSLocalizedString("copyTitle"), options: [],icon: .init(systemImageName: "doc.on.doc"))
        
        // 创建 category
        let category = UNNotificationCategory(identifier: Identifiers.reminderCategory,
                                              actions: [copyAction],
                                              intentIdentifiers: [],
                                              options: [.hiddenPreviewsShowTitle])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        return true
    }
    
    
    
    // 处理点击后的操作
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        notificatonHandler(userInfo: response.notification.request.content.userInfo)
        pawManager.shared.clickMessageHandler()
        completionHandler()

    }
    
    func notificatonHandler(userInfo: [AnyHashable : Any] ){
        let url: URL? = {
            if let url = userInfo["url"] as? String {
                return URL(string: url)
            }
            return nil
        }()

        // URL 直接打开
        if let url = url {
            pawManager.shared.openUrl(url: url)
            return
        }
        
        
        
    }

    // 处理应用程序在前台是否显示通知
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        notificatonHandler(userInfo: notification.request.content.userInfo)
        generator.prepare()
        generator.selectionChanged()
        
        
        completionHandler(.sound)
        
        
    }
    
    
}
