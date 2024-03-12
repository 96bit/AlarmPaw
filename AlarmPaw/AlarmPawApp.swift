//
//  AlarmPawApp.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/13.
//

import SwiftUI
import RealmSwift

@main
struct AlarmPawApp: SwiftUI.App {
    @Environment(\.scenePhase) var phase
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var paw = pawManager.shared
    @AppStorage("defaultPageViewShow") var page:PageView = .message
    @AppStorage(settings.firstStartApp.rawValue) var firstart:Bool = true
    @State var showDelNotReadAlart:Bool = false
    @State var showDelReadAlart:Bool = false
    @State var showAlart:Bool = false
    @State var activeName:String = ""
    @State var toastText:String = ""
    
    private let timerz = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    var body: some Scene {
        WindowGroup {
            
                ContentView()
                    .environmentObject(pawManager.shared)
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        if let badge = RealmManager.shared.getUnreadCount(){
                            paw.changeBadge(badge: badge)
                        }
                    }
                    .alert(isPresented: $showAlart) {
                        Alert(title:
                                Text(NSLocalizedString("changeTipsTitle", comment: "操作不可逆！")),
                              message:
                                Text( activeName == "alldelnotread" ?
                                      NSLocalizedString("changeTips1SubTitle", comment: "是否确认删除所有未读消息!") : NSLocalizedString("changeTips2SubTitle", comment: "是否确认删除所有已读消息!")
                                    ),
                              primaryButton:
                                .destructive(
                                    Text(NSLocalizedString("deleteTitle", comment: "删除")),
                                    action: {
                                        RealmManager.shared.allDel( activeName == "alldelnotread" ? 1 : 0)
                                        self.toastText = NSLocalizedString("controlSuccess", comment: "操作成功")
                                    }
                                ), secondaryButton: .cancel())
                    }
                    .task {
                        paw.monitorNetwork()
                        paw.monitorNotification()
                    }
                    .onChange(of: phase) { value in
                        self.backgroundModeHandler(of: value)
                    }
                    .toast(info: $toastText)
                    .onAppear {
                        if RealmManager.shared.getUnreadCount() == 0 && firstart {
                            for item in Message.messages{
                                let _ = RealmManager.shared.addObject(item)
                            }
                            self.firstart = false
                        }
                        
                    }
                    .onOpenURL { url in
                        
                        guard let scheme = url.scheme,
                              let host = url.host(),
                              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else{ return }
                        let params = components.getParams()
                        debugPrint(scheme, host, params)
                        
                        if host == "login"{
                            if let url = params["url"]{
                                paw.scanUrl = url
                                paw.showLogin.toggle()
                            }else{
                                self.toastText =  NSLocalizedString("paramsError", comment: "参数错误")
                            }
                           
                        }else if host == "add"{
                            if let url = params["url"]{
                                let (mode1,msg) = paw.addServer(url: url)
                                self.toastText = msg
                                paw.showServer = mode1
                            }else{
                                self.toastText = NSLocalizedString("paramsError", comment: "参数错误")
                            }
                        }
                       
                    }
                    .fullScreenCover(isPresented: $paw.showLogin){
                        LoginView(registerUrl: paw.scanUrl)
                    }
                    

            
        }
        
    }
    
    
    
    func backgroundModeHandler(of value:ScenePhase){
        switch value{
        case .active:
            print("app active")
            if let name = QuickAction.selectAction?.userInfo?["name"] as? String{
                QuickAction.selectAction = nil
                print(name)
                self.page = .message
                switch name{
                case "allread":
                    RealmManager.shared.allRead()
                    self.toastText = NSLocalizedString("controlSuccess", comment: "操作成功")
                case "alldelread","alldelnotread":
                    self.activeName = name
                    self.showAlart.toggle()
                default:
                    break
                }
            }
        case .background:
            paw.addQuickActions()
            
        default:
            break
            
        }
    }
}
