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
        NavigationStack{
            Group{
                switch page{
                case .message:
                    MessageView()
                    
                case .setting:
                    SettingView()
                }
            }.toolbar {
                ToolbarItem(placement: .bottomBar) {
                    
                    HStack{
                        Spacer()
                        VStack {
                            Image(systemName: "ellipsis.message")
                            Text(NSLocalizedString("bottomBarMsg")).font(.system(size: 10))
                        }
                        .foregroundStyle(self.page == .message ? Color("textBlack") : Color.gray)
                        .onTapGesture {
                            self.page = .message
                            
                        }
                        Spacer()
                        Spacer()
                        VStack{
                            Image(systemName: "gearshape")
                            Text(NSLocalizedString("bottomBarSettings")).font(.system(size: 10))
                        }
                        .foregroundStyle(self.page == .setting ? Color("textBlack") : Color.gray)
                        .onTapGesture {
                            self.page = .setting
                        }
                        Spacer()
                        
                    }
                    
                    
                }
                
            }
            .fullScreenCover(isPresented: $paw.showSafariWebView) {
                if let url = paw.showSafariWebUrl{
                    SFSafariViewWrapper(url: url)
                        .ignoresSafeArea()
                }
                
            }
            
            
            
        }
        
    }
}

#Preview {
    ContentView().environmentObject(pawManager.shared)
}
