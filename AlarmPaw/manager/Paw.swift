//
//  Paw.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/16.
//

import Foundation
import UIKit
import SwiftUI
import RealmSwift
import Network
import Combine
import UserNotifications

class pawManager: ObservableObject{
    
    @AppStorage(settings.deviceToken) var deviceToken:String = ""
    @AppStorage(settings.badgemode,store: defaultStore) var badgeMode:badgeAutoMode = .auto
    @AppStorage(settings.server) var servers:[serverInfo] = [serverInfo.serverDefault]
    @AppStorage(settings.defaultPage) var page:pageState.tabPage = .message
    @AppStorage(settings.messageFirstShow) var firstShow = true
    @AppStorage(settings.messageShowMode) var showMessageMode:MessageGroup = .all
    @AppStorage(settings.emailConfig,store: defaultStore) var email:emailConfig = emailConfig.data
    
    @Published var isNetworkAvailable = false
    @Published var cloudCount = 0
    
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined

    
    
    
    
    private var cancellables: Set<AnyCancellable> = []
    
    static let shared = pawManager()
    private let session = URLSession(configuration: .default)
    private init() {}
    
    
    
    func changeBadge(badge:Int){
        
        dispatch_sync_safely_main_queue {
            if badge == -1{
                UNUserNotificationCenter.current().setBadgeCount(0)
            }
            
            if self.badgeMode == .auto{
                UNUserNotificationCenter.current().setBadgeCount(badge)
            }
        }
        
    }
    
    
    
    
    func changeDeviceToken(_ token:String){
        self.deviceToken = token
    }
    
    
    
    func openUrl(url: String ){
        if  let url = URL(string: url) {
            self.openUrl(url: url )
        }
    }
    
    
    
    func openUrl(url: URL) {
        if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: true]) { success in
                if !success {
                    // 打不开Universal Link时，则用内置 safari 打开
                    pageState.shared.webUrl = url.path()
                    pageState.shared.fullPage = .web
                    
                }
            }
        }
        else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func copy(text:String){
        UIPasteboard.general.string = text
    }
    
    // MARK: 注册设备
    func registerForRemoteNotifications() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay], completionHandler: { (_ granted: Bool, _: Error?) -> Void in
            
            if granted {
                self.dispatch_sync_safely_main_queue {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            }
            else {
                print("没有打开推送")
            }
        })
    }
    
    
    // MARK: 将代码安全的运行在主线程
    func dispatch_sync_safely_main_queue(_ block: () -> ()) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }
    
    func dispatch_async_queue(_ qos:DispatchQoS.QoSClass = .background,of block: @escaping () -> ()){
        DispatchQueue.global(qos: qos).async{
            block()
        }
    }
    
    
    func clickMessageHandler(){
        page = .message
    }
    
    
    
    func startsWithHttpOrHttps(_ urlString: String) -> Bool {
        let pattern = "^(http|https)://.*"
        let test = NSPredicate(format:"SELF MATCHES %@", pattern)
        return test.evaluate(with: urlString)
    }
    
}



extension pawManager{
    
    
    func fetch<T:Codable>(url:String) async throws -> T?{
        guard let requestUrl = URL(string: url) else {return  nil}
        let data = try await session.data(for: URLRequest(url: requestUrl))
        let result = try JSONDecoder().decode(baseResponse<T>.self, from: data)
        return result.data
    }
    
    func fetchRaw<T:Codable>(url:String) async throws -> T?{
        guard let requestUrl = URL(string: url) else {return  nil}
        let data = try await session.data(for: URLRequest(url: requestUrl))
        let result = try JSONDecoder().decode(T.self, from: data)
        return result
    }
    
    func fetchVoid(url:String) async-> Bool {
        guard let requestUrl = URL(string: url) else { return false }
        do{
            _ = try await session.data(for: URLRequest(url: requestUrl))
            return true
        }catch{
           return false
        }
        
    }
    
    
    func health(url: String) async-> Bool {
        do{
            if let health: String = try await fetchRaw(url: url){
                return health == "ok"
            }
        }catch{
            return false
        }
        
        return false
        
    }
    
    func healthAll() async-> Bool{
        let servers = pawManager.shared.servers
        var result:Bool = true
        for server in servers{
            let ok =  await health(url: server.url + "/health")
            if !ok{
                result = false
            }
        }
        return result
    }
    
    func healthAllColor() async-> Color{
        let servers = pawManager.shared.servers
        var hasTrue = false
        var hasFalse = false
        
        for server in servers {
            let ok = await health(url: server.url + "/health")
            if ok {
                hasTrue = true
                if let index = servers.firstIndex(where: {$0.id == server.id}){
                    self.dispatch_sync_safely_main_queue {
                        pawManager.shared.servers[index].status = true
                    }
                }
            } else {
                hasFalse = true
                if let index = servers.firstIndex(where: {$0.id == server.id}){
                    self.dispatch_sync_safely_main_queue {
                        pawManager.shared.servers[index].status = false
                    }
                }
            }
        }
        
        if hasTrue && hasFalse {
            return .orange
        } else if hasTrue {
            return .green
        } else {
            return .red
        }
        
    }
    
    func registerAll() async {
        for server in servers{
            await register(server: server)
        }
    }

    
    func register(server: serverInfo) async  {
        
        print("注册设备")
        guard let index = servers.firstIndex(where: {$0.id == server.id}) else {
            print("没有获取到")
            return
        }
        
        do {
            if let deviceInfo:DeviceInfo? = try await fetch(url: server.url + "/register/" + self.deviceToken + "/" + servers[index].key){
                
                self.dispatch_sync_safely_main_queue {
                    servers[index].key = deviceInfo?.pawKey ?? ""
//                        print("注册设备:", deviceInfo)
                }
            }
            
            
        }catch{
            print(error)
        }
        
    }
    
    func openSetting(){
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(settingsURL)
    }
    
    
}

extension pawManager{
    func monitorNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            print("网络发生变化",path)
            self.dispatch_sync_safely_main_queue {
                self.isNetworkAvailable = path.status == .satisfied
                if self.isNetworkAvailable {
                    self.registerForRemoteNotifications()
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    // 监听通知权限变化
    func monitorNotification(){
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                self.checkNotificationPermissionStatus()
            }
            .store(in: &cancellables)
        self.checkNotificationPermissionStatus()
    }
    
    func checkNotificationPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionStatus = settings.authorizationStatus
                
                if settings.authorizationStatus == .authorized {
                    //  MARK: 注册设备
                    pawManager.shared.registerForRemoteNotifications()
                }
                
            }
        }
    }
}


extension pawManager{
    func addServer(url: String)-> (Bool,String){
        var toastText:String = ""
        if !startsWithHttpOrHttps(url){
            toastText = NSLocalizedString("verifyFail",comment: "")
            return (false,toastText)
        }
        
        let count = self.servers.filter({$0.url == url}).count
        
        if count == 0{
            if serverInfo.serverDefault.url == url {
                self.servers.insert(serverInfo(url: url, key: ""), at: 0)
            }else{
                self.servers.append(serverInfo(url: url, key: ""))
            }
            toastText = NSLocalizedString("addSuccess",comment: "")
        }else{
            toastText =  NSLocalizedString("serverExist",comment: "")
            return (false,toastText)
        }
        
        Task(priority: .userInitiated) {
            await self.registerAll()
        }
        
        return (true,toastText)
    }
}

extension pawManager{
    func addQuickActions(){
        UIApplication.shared.shortcutItems = QuickAction.allShortcutItems
    }
}
