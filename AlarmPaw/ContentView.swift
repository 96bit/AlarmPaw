//
//  ContentView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/13.
//

import SwiftUI
import RealmSwift


enum PageView :String{
    case message = "message"
    case setting = "setting"
}


struct ContentView: View {
    @AppStorage("defaultPageViewShow") var page:PageView = .message
    @EnvironmentObject var paw: pawManager
    @ObservedResults(Message.self) var messages
    var body: some View {
        TabView(selection: $page) {
            // MARK: 信息页面
            NavigationStack{
                
                MessageView()
                
                    .navigationTitle(NSLocalizedString("bottomBarMsg",comment: ""))
            }.tabItem { Label(NSLocalizedString("bottomBarMsg",comment: ""), systemImage: "ellipsis.message") }
                .tag(PageView.message)
                .badge(messages.where({!$0.isRead}).count)
            // MARK: 设置页面
            NavigationStack{
                SettingView()
                    .navigationTitle(NSLocalizedString("bottomBarSettings",comment: ""))
            }.tabItem { Label(NSLocalizedString("bottomBarSettings",comment: ""), systemImage: "gearshape") }
                .tag(PageView.setting)
        }
        .sheet(isPresented: $paw.showServer) {
            ServerListView(showClose: true)
        }
        
        .fullScreenCover(isPresented: $paw.showSafariWebView) {
            if let url = paw.showSafariWebUrl{
                SFSafariViewWrapper(url: url)
                    .ignoresSafeArea()
            }
            
            
        }
        
        
        
        //willEnterForegroundNotification
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            Task(priority: .background){
                let messageNotCloud = messages.where({!$0.cloud})
                if messageNotCloud.count == 0{
                    print("没有数据")
                }
                let result = await CloudKitManager.shared.uploadCloud(Array(messageNotCloud))
                do{
                    let realm = try await Realm()
                    try realm.write{
                        for message in result{
                            if let thawedObject = message.thaw(){
                                thawedObject.cloud = true
                            }
                            
                        }
                    }
                    
                }catch{
                    print(error)
                }
                
            }
        }
        
        
    }
    
    
    
}

#Preview {
    ContentView().environmentObject(pawManager.shared)
}
