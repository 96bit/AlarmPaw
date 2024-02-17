//
//  MessageView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/16.
//

import SwiftUI
import RealmSwift


struct MessageView: View {
    @EnvironmentObject var paw:pawManager
    @State private var searchText = ""
    @State private var showAction = false
    @State private var showHelp = false
    @State private var toastText = ""
    @State private var helpviewSize:CGSize = .zero
    var body: some View {
        VStack{
            if paw.showMessageMode == .all{
                AllMessageView(searchText: $searchText)
            }else {
                GroupMessageView(searchText: $searchText)
            }
        }
        
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                
                Button{
                    self.showHelp = true
                }label:{
                    Image(systemName: "questionmark.circle")
                    
                } .foregroundStyle(Color("textBlack"))
                    .accessibilityIdentifier("HelpButton")
            }
            
            ToolbarItem{
                Button{
                    withAnimation(.interactiveSpring) {
                        self.toastText = paw.showMessageMode == .all ? NSLocalizedString("groupMessageMode") :NSLocalizedString("defaultMessageMode")
                        paw.showMessageMode =  paw.showMessageMode == .all ? .group : .all
                    }
                }label: {
                    Image(systemName: paw.showMessageMode == .all ? "rectangle.3.group.bubble" : "rectangle.3.group")
                    
                } .foregroundStyle(Color("textBlack"))
                
            }
            
            ToolbarItem{
                Button{
                    self.showAction = true
                }label: {
                    Image("baseline_delete_outline_black_24pt")
                    
                }  .foregroundStyle(Color("textBlack"))
                
                
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
        .actionSheet(isPresented: $showAction) {
            ActionSheet(title: Text(NSLocalizedString("deleteTimeMessage")),buttons: [
                .destructive(Text(NSLocalizedString("allTime")), action: {
                    deleteMessage(.allTime)
                }),
                .destructive(Text(NSLocalizedString("monthAgo")), action: {
                    deleteMessage( .lastMonth)
                }),
                .destructive(Text(NSLocalizedString("weekAgo")), action: {
                    deleteMessage( .lastWeek)
                }),
                .destructive(Text(NSLocalizedString("dayAgo")), action: {
                    deleteMessage( .lastDay)
                }),
                .destructive(Text(NSLocalizedString("hourAgo")), action: {
                    deleteMessage( .lastHour)
                }),
                .default(Text(NSLocalizedString("allMarkRead")), action: {
                    deleteMessage( .markRead)
                }),
                .cancel()
                
            ])
        }
        .fullScreenCover(isPresented: $showHelp, content: {
            CustomHelpView()
        })
        .toast(info: $toastText)
    }
    
    
    
}




extension MessageView{
    
    func deleteMessage(_ mode: mesAction){
        
        let realm = RealmManager.shared
        
        if realm.getObject()?.count == 0{
            self.toastText = NSLocalizedString("nothingMessage")
            return
        }
        
        var date = Date()
        
        switch mode {
        case .allTime:
            let alldata = realm.getObject()
            let _ =  realm.deleteObjects(alldata)
            self.toastText =  NSLocalizedString("deleteAllMessage")
            return
        case .markRead:
            
            let allData = realm.getObject()?.where({!$0.isRead})
            let _ = realm.updateObjects(allData) { data in
                data?.isRead = true
            }
            self.toastText =  NSLocalizedString("allMarkRead")
            return
        case .lastHour:
            date = Date().someHourBefore(1)
        case .lastDay:
            date = Date().someDayBefore(0)
           
        case .lastWeek:
            date = Date().someDayBefore(7)
        case .lastMonth:
            date = Date().someDayBefore(30)
            
            
        }
        
        let alldata = realm.getObject()?.where({$0.createDate < date})
        
        let _ = realm.deleteObjects(alldata)
        
        self.toastText = NSLocalizedString("deleteSuccess")
        
    }

}







#Preview {
    NavigationStack{
        MessageView()
    }
    
}
