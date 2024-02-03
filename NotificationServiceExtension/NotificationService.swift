//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by He Cho on 2024/1/13.
//

import Intents
import Kingfisher
import MobileCoreServices
import SwiftyJSON
import UIKit
import UserNotifications
import UniformTypeIdentifiers
import SwiftUI
import Foundation
import RealmSwift
import UIKit

class NotificationService: UNNotificationServiceExtension {
    
    @AppStorage(settings.badgemode.rawValue,store: UserDefaults(suiteName: settings.groupName.rawValue)) var badgeMode:badgeAutoMode = .auto
    @AppStorage(settings.emailConfig.rawValue,store: UserDefaults(suiteName: settings.groupName.rawValue)) var email:emailConfig = emailConfig.data
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    lazy var realm: Realm? = {
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
        return try? Realm()
    }()
    
    
    /// 保存图片到缓存中
    /// - Parameters:
    ///   - cache: 使用的缓存
    ///   - data: 图片 Data 数据
    ///   - key: 缓存 Key
    func storeImage(cache: ImageCache, data: Data, key: String) async {
        return await withCheckedContinuation { continuation in
            cache.storeToDisk(data, forKey: key, expiration: StorageExpiration.never) { _ in
                continuation.resume()
            }
        }
    }
    
    /// 使用 Kingfisher.ImageDownloader 下载图片
    /// - Parameter url: 下载的图片URL
    /// - Returns: 返回 Result
    func downloadImage(url: URL) async -> Result<ImageLoadingResult, KingfisherError> {
        return await withCheckedContinuation { continuation in
            Kingfisher.ImageDownloader.default.downloadImage(with: url, options: nil) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    
    /// 下载推送图片
    /// - Parameter imageUrl: 图片URL字符串
    /// - Returns: 保存在本地中的`图片 File URL`
    fileprivate func downloadImage(_ imageUrl: String, _ bestAttemptContent: UNMutableNotificationContent) async -> String? {
        
        
        guard let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: settings.groupName.rawValue),
              let cache = try? ImageCache(name: "shared", cacheDirectoryURL: groupUrl),
              let imageResource = URL(string: imageUrl)
        else {
            return nil
        }
        
        // 先查看图片缓存
        if cache.diskStorage.isCached(forKey: imageResource.cacheKey) {
            return cache.cachePath(forKey: imageResource.cacheKey)
        }
        
        // 下载图片
        guard let result = try? await downloadImage(url: imageResource).get() else {
            return nil
        }
        
        
        // 缓存图片
        await storeImage(cache: cache, data: result.originalData, key: imageResource.cacheKey)
        
        
        return cache.cachePath(forKey: imageResource.cacheKey)
        //        return result.originalData
    }
    
    /// 为 Notification Content 设置图片
    /// - Parameter bestAttemptContent: 要设置的 Notification Content
    /// - Returns: 返回设置图片后的 Notification Content
    fileprivate func setImage(content bestAttemptContent: UNMutableNotificationContent) async -> UNMutableNotificationContent {
        let userInfo = bestAttemptContent.userInfo
        
        guard let imageUrl = userInfo["image"] as? String,
              startsWithHttpOrHttps(imageUrl),
              let imageFileUrl = await downloadImage(imageUrl,bestAttemptContent)
        else {
            return bestAttemptContent
        }
        
        
        
        let copyDestUrl = URL(fileURLWithPath: imageFileUrl).appendingPathExtension(".tmp")
        // 将图片缓存复制一份，推送使用完后会自动删除，但图片缓存需要留着以后在历史记录里查看
        try? FileManager.default.copyItem(
            at: URL(fileURLWithPath: imageFileUrl),
            to: copyDestUrl
        )
        
        if let attachment = try? UNNotificationAttachment(
            identifier: "image",
            url: copyDestUrl,
            //kUTTypePNG
            options: [UNNotificationAttachmentOptionsTypeHintKey: "public.png"]
        ) {
            bestAttemptContent.attachments = [attachment]
        }
        
        bestAttemptContent.userInfo["imageFile"] = imageFileUrl
        
        return bestAttemptContent
    }
    
    /// 为 Notification Content 设置ICON
    /// - Parameter bestAttemptContent: 要设置的 Notification Content
    /// - Returns: 返回设置ICON后的 Notification Content
    fileprivate func setIcon(content bestAttemptContent: UNMutableNotificationContent) async -> UNMutableNotificationContent {
        if #available(iOSApplicationExtension 15.0, *) {
            
            
            let userInfo = bestAttemptContent.userInfo
            
            guard let imageUrl = userInfo["icon"] as? String,
                  startsWithHttpOrHttps(imageUrl),
                  let imageFileUrl = await downloadImage(imageUrl,bestAttemptContent) else {
                return bestAttemptContent
            }
            
            
            
            var personNameComponents = PersonNameComponents()
            personNameComponents.nickname = bestAttemptContent.title
            
            let avatar = INImage(imageData: NSData(contentsOfFile: imageFileUrl)! as Data)
            let senderPerson = INPerson(
                personHandle: INPersonHandle(value: "", type: .unknown),
                nameComponents: personNameComponents,
                displayName: personNameComponents.nickname,
                image: avatar,
                contactIdentifier: nil,
                customIdentifier: nil,
                isMe: false,
                suggestionType: .none
            )
            let mePerson = INPerson(
                personHandle: INPersonHandle(value: "", type: .unknown),
                nameComponents: nil,
                displayName: nil,
                image: nil,
                contactIdentifier: nil,
                customIdentifier: nil,
                isMe: true,
                suggestionType: .none
            )
            
            let intent = INSendMessageIntent(
                recipients: [mePerson],
                outgoingMessageType: .outgoingMessageText,
                content: bestAttemptContent.body,
                speakableGroupName: INSpeakableString(spokenPhrase: personNameComponents.nickname ?? ""),
                conversationIdentifier: bestAttemptContent.threadIdentifier,
                serviceName: nil,
                sender: senderPerson,
                attachments: nil
            )
            
            intent.setImage(avatar, forParameterNamed: \.sender)
            
            let interaction = INInteraction(intent: intent, response: nil)
            interaction.direction = .incoming
            
            try? await interaction.donate()
            
            do {
                let content = try bestAttemptContent.updating(from: intent) as! UNMutableNotificationContent
                return content
            }
            catch {
                print(error)
            }
            
            return bestAttemptContent
        }
        else {
            return bestAttemptContent
        }
    }
    
    
    
    /// 保存推送
    /// - Parameter userInfo: 推送参数
    /// 如果用户携带了 `isarchive` 参数，则以 `isarchive` 参数值为准
    fileprivate func archive(_ userInfo: [AnyHashable: Any]) {
        
        let alert = (userInfo["aps"] as? [String: Any])?["alert"] as? [String: Any]
        let title = alert?["title"] as? String
        let body = alert?["body"] as? String
        let group = (userInfo["aps"] as? [String: Any])?["thread-id"] as? String
        let image = userInfo["image"] as? String
        let icon = userInfo["icon"] as? String
        let url = userInfo["url"] as? String
        
        
        var isArchive: Bool{
            if let archive = userInfo["isarchive"] as? String {
                return archive == "1" ? true : false
            }
            return  true
        }
        
        
        if isArchive == true {
            try? realm?.write {
                let message = Message()
                message.title = title
                message.image = image
                message.icon = icon
                message.body = body
                message.url = url
                message.group = group ?? "默认"
                message.createDate = Date()
                realm?.add(message)
            }
        }
        
        
    }
    
    
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        
        
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }
        
        let userInfo = bestAttemptContent.userInfo
        
       
        if badgeMode == .custom{
            // MARK: 通知角标 .custom
            if let badgeStr = userInfo["badge"] as? String, let badge = Int(badgeStr) {
                bestAttemptContent.badge = NSNumber(value: badge)
            }
        }else{
            // MARK: 通知角标 .auto
            let messages = realm?.objects(Message.self).where {!$0.isRead}
            bestAttemptContent.badge = NSNumber(value:  messages?.count ?? 0 + 1)
        }
        
        
        // MARK:  通知中断级别
        if let level = userInfo["level"] as? String {
            let interruptionLevels: [String: UNNotificationInterruptionLevel] = [
                "passive": UNNotificationInterruptionLevel.passive,
                "active": UNNotificationInterruptionLevel.active,
                "timeSensitive": UNNotificationInterruptionLevel.timeSensitive,
                "timesensitive": UNNotificationInterruptionLevel.timeSensitive,
                "critical": UNNotificationInterruptionLevel.critical,
            ]
            bestAttemptContent.interruptionLevel = interruptionLevels[level] ?? .active
        }
        
        // MARK: 保存消息
        archive(userInfo)
        
        // MARK: 发送邮件
        mailAuto(userInfo)
        
        Task.init {
            
            // 设置推送图标
            let iconResult = await setIcon(content: bestAttemptContent)
            // 设置推送图片
            let imageResult = await self.setImage(content: iconResult)
            
            
            contentHandler(imageResult)
        }
    }
    
    // MARK: 发送邮件
    private func mailAuto(_ userInfo:[AnyHashable: Any]){
        Task{
            if let action = userInfo["action"] as? String{
                if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted) {
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    sendMail(config: email, title: "自动化\(action)", text: jsonString ?? "数据编码失败")
                } else {
                    print("转换失败")
                    sendMail(config: email, title: "自动化\(action)", text: "数据编码失败")
                }
            }
        }
        
    }
    
    
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}

