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
    
    var body: some View {
        
        
        TabView(selection: $page) {
            // MARK: 信息页面
            NavigationStack{
                MessageView()
                    .navigationTitle(NSLocalizedString("bottomBarMsg"))
            }.tabItem { Label(NSLocalizedString("bottomBarMsg"), systemImage: "ellipsis.message") }
                .tag(PageView.message)
            // MARK: 设置页面
            NavigationStack{
                SettingView()
                    .navigationTitle(NSLocalizedString("bottomBarSettings"))
            }.tabItem { Label(NSLocalizedString("bottomBarSettings"), systemImage: "gearshape") }
                .tag(PageView.setting)
        }  .fullScreenCover(isPresented: $paw.showSafariWebView) {
            if let url = paw.showSafariWebUrl{
                SFSafariViewWrapper(url: url)
                    .ignoresSafeArea()
            }
            
        }
    
      
    }
    
    
    
}

#Preview {
    ContentView().environmentObject(pawManager.shared)
}
