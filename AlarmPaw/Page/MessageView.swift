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
    @State var searchText = ""
    @ObservedResults(Message.self,
                     sortDescriptor: SortDescriptor(keyPath: "createDate",
                                                    ascending: false)) var messages

    @State private var showAction = false
    @State private var imageID = ""
    @State private var showHelp = false
    @State private var expandedStates: [String: Bool] = [:]
    @State private var toastText = ""
    @State private var helpviewSize:CGSize = .zero
    var body: some View {
        VStack{
            
            messageModeView
           
        }
        .navigationTitle(NSLocalizedString("bottomBarMsg"))
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                
                Button{
                    self.showHelp = true
                }label:{
                    Image(systemName: "questionmark.circle")
                    
                } .foregroundStyle(Color("textBlack"))
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
    private var messageModeView: some View{
        List{
            
            if messages.count == 0 && paw.firstShow{
                
                if paw.showMessageMode == .all{
                    showDemoView
                }else {
                    showDemoGroupView
                }
               
               
            }
            
            if paw.showMessageMode == .all{
                showAllMessage
            }else {
                showGroupView
            }
            
            
            
        }.listStyle(.sidebar)
        
        .searchable(text: $searchText)
    }
    
}



extension MessageView{
    private var showDemoView: some View{
        ForEach(Message.messages,id:\.id){item in
            MessageItem(message: item, imageID: $imageID,toastText:$toastText)
                .swipeActions(edge: .leading) {
                    Button {
                        item.isRead = !item.isRead
                        self.toastText = NSLocalizedString("messageModeChanged")
                    } label: {
                        Label(item.isRead ? NSLocalizedString("markNotRead") :  NSLocalizedString("markRead") , systemImage: item.isRead ? "envelope.open": "envelope")
                    }.tint(.blue)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        item.title = NSLocalizedString("deleteSuccess")
                    } label: {
                        Label(NSLocalizedString("deleteTitle"), systemImage: "trash")
                    }.tint(.blue)
                }
            
        }
    }
}

extension MessageView{
    private var showDemoGroupView: some View{
        let msgMap = createMessageListMap(Message.messages)
        
        return ForEach(msgMap.keys.sorted(), id: \.self) { key in
            let isExpandedBinding = Binding(
                get: { self.expandedStates[key, default: false] },
                set: { self.expandedStates[key] = $0 }
            )
            Section {
                DisclosureGroup(isExpanded: isExpandedBinding){
                    if let messageResult = msgMap[key]{
                        ForEach(messageResult, id: \.id) { message in
                            
                            if isExpandedBinding.wrappedValue {
                                VStack(spacing:20){
                                    MessageItem(message: message, imageID: $imageID,toastText:$toastText)
                                    
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        let _ = RealmManager.shared.updateObject(message) { item2 in
                                            item2.isRead = !item2.isRead
                                            self.toastText = NSLocalizedString("messageModeChanged")
                                        }
                                    } label: {
                                        Label(message.isRead ? NSLocalizedString("markNotRead") :  NSLocalizedString("markRead"), systemImage: message.isRead ? "envelope.open": "envelope")
                                    }.tint(.blue)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        
                                        let _ = RealmManager.shared.deleteObject(message)
                                        
                                    } label: {
                                        Label(NSLocalizedString("deleteTitle"), systemImage: "trash")
                                    }
                                }
                                .animation(.interactiveSpring, value: message.id)
                                Divider()
                                
                            }
                            
                        }
                    }
                }label: {
                    HStack{
                        Text(key)
                        Spacer()
                        let readCount = msgMap[key]?.filter({!$0.isRead}).count ?? 0
                        Text(readCount == 0 ?NSLocalizedString("nothing") : "\(readCount)")
                            .fontWeight(.bold)
                        Text(NSLocalizedString("notread"))
                            .font(.system(size: 10))
                            .foregroundStyle(.gray)
                        
                    }
                }
                .id(UUID())
            }header: {
                Text(String(format: NSLocalizedString("someMessageCount"), msgMap[key]?.count ?? 0))
            }
            .swipeActions(edge: .trailing) {
                if !isExpandedBinding.wrappedValue{
                    Button(role: .destructive) {
                        let realm = RealmManager.shared
                        let deleitem = realm.getObject()?.where({$0.group == key})
                        if let deleitem = deleitem{
                            let _ = realm.deleteObjects(deleitem)
                        }
                    } label: {
                        Label(NSLocalizedString("deleteMessageGroup"), systemImage: "trash")
                    }
                }
                
            }
            .swipeActions(edge: .leading) {
                if !isExpandedBinding.wrappedValue{
                    Button {
                        let realm = RealmManager.shared
                        let alldata = realm.getObject()?.where({$0.group == key})
                        if let alldata = alldata{
                            let _ = realm.updateObjects(alldata) { data in
                                data?.isRead = true
                            }
                        }
                    } label: {
                        Label(NSLocalizedString("groupMarkRead"), systemImage: "envelope")
                    }.tint(.blue)
                }
            }
        }
        
    }
}



extension MessageView{
    private var showAllMessage:some View{
        ForEach(messageFilterData(messages), id: \.id) { item in
            
            MessageItem(message: item, imageID: $imageID,toastText:$toastText)
                .onAppear{
                    if paw.firstShow{
                        paw.firstShow = false
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        let _ = RealmManager.shared.updateObject(item) { item2 in
                            item2.isRead = !item2.isRead
                            self.toastText = NSLocalizedString("messageModeChanged")
                        }
                    } label: {
                        Label(item.isRead ? NSLocalizedString("markNotRead") :  NSLocalizedString("markRead"), systemImage: item.isRead ? "envelope.open": "envelope")
                    }.tint(.blue)
                }
                .animation(.interactiveSpring, value: item.id)
        }.onDelete(perform: $messages.remove)
    }
}

extension MessageView{
    private var showGroupView:some View{
        let msgMap = createMessageMap(messages)
        return ForEach(msgMap.keys.sorted(), id: \.self) { key in
            let isExpandedBinding = Binding(
                get: { self.expandedStates[key, default: false] },
                set: { self.expandedStates[key] = $0 }
            )
            Section {
                DisclosureGroup(isExpanded: isExpandedBinding){
                    if let messageResult = msgMap[key]{
                        ForEach(messageResult, id: \.id) { message in
                            
                            if isExpandedBinding.wrappedValue {
                                VStack(spacing:20){
                                    MessageItem(message: message, imageID: $imageID,toastText:$toastText)
                                    
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        let _ = RealmManager.shared.updateObject(message) { item2 in
                                            item2.isRead = !item2.isRead
                                            self.toastText = NSLocalizedString("messageModeChanged")
                                        }
                                    } label: {
                                        Label(message.isRead ? NSLocalizedString("markNotRead") :  NSLocalizedString("markRead"), systemImage: message.isRead ? "envelope.open": "envelope")
                                    }.tint(.blue)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        
                                        let _ = RealmManager.shared.deleteObject(message)
                                        
                                    } label: {
                                        Label(NSLocalizedString("deleteTitle"), systemImage: "trash")
                                    }
                                }
                                .animation(.interactiveSpring, value: message.id)
                                Divider()
                                
                            }
                            
                        }
                    }
                }label: {
                    HStack{
                        Text(key)
                        Spacer()
                        let readCount = msgMap[key]?.where({!$0.isRead}).count ?? 0
                        Text(readCount == 0 ?NSLocalizedString("nothing") : "\(readCount)")
                            .fontWeight(.bold)
                        Text(NSLocalizedString("notread"))
                            .font(.system(size: 10))
                            .foregroundStyle(.gray)
                        
                    }
                }
                .id(UUID())
            }header: {
                Text(String(format: NSLocalizedString("someMessageCount"), msgMap[key]?.count ?? 0))
            }
            .swipeActions(edge: .trailing) {
                if !isExpandedBinding.wrappedValue{
                    Button(role: .destructive) {
                        let realm = RealmManager.shared
                        let deleitem = realm.getObject()?.where({$0.group == key})
                        if let deleitem = deleitem{
                            let _ = realm.deleteObjects(deleitem)
                        }
                    } label: {
                        Label(NSLocalizedString("deleteMessageGroup"), systemImage: "trash")
                    }
                }
                
            }
            .swipeActions(edge: .leading) {
                if !isExpandedBinding.wrappedValue{
                    Button {
                        let realm = RealmManager.shared
                        let alldata = realm.getObject()?.where({$0.group == key})
                        if let alldata = alldata{
                            let _ = realm.updateObjects(alldata) { data in
                                data?.isRead = true
                            }
                        }
                    } label: {
                        Label(NSLocalizedString("groupMarkRead"), systemImage: "envelope")
                    }.tint(.blue)
                }
            }
        }
        
        
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
    
    func createMessageMap(_ messages:Results<Message>) -> [String:Results<Message>] {
        var msgMap:[String:Results<Message>] = [:]
        
        for  message in messages{
            let group = message.group ??  NSLocalizedString("deleteGroup")
            if let _ = msgMap[group]{
                continue
            }else{
                
                let results = messages.where({$0.group == group})
                
                if searchText == ""{
                    
                    msgMap[group]  = results.sorted(by: [
                        SortDescriptor(keyPath: "isRead", ascending: true),
                        SortDescriptor(keyPath: "createDate", ascending: false)
                    ])
                }else{
                    let resultgroup = results.filter(NSPredicate(format: "title CONTAINS[c] %@ OR body CONTAINS[c] %@", searchText, searchText))
                    if resultgroup.count > 0 {
                        msgMap[group]  = resultgroup.sorted(by: [
                            SortDescriptor(keyPath: "isRead", ascending: true),
                            SortDescriptor(keyPath: "createDate", ascending: false)
                        ])
                    }
                    
                }
               
            }
            
        }
        
        return msgMap
        
    }
    
    func createMessageListMap(_ messages:[Message]) -> [String:[Message]] {
        var msgMap:[String:[Message]] = [:]
        
        for  message in messages{
            let group = message.group ??  NSLocalizedString("deleteGroup")
            if let _ = msgMap[group]{
                continue
            }else{
                
                let results = messages.filter({$0.group == group})
                
                if searchText == ""{
                    
                    msgMap[group]  = results.sorted(by: { a, b in
                        if a.isRead == b.isRead{
                            return a.createDate > b.createDate
                        }else{
                            return a.isRead
                        }
                    })
                }else{
                    let resultgroup = results.filter({
                        (($0.title?.contains(searchText)) ?? false) || (($0.body?.contains(searchText)) ?? false)
                    })
                    if resultgroup.count > 0 {
                        msgMap[group]  = resultgroup.sorted(by: { a, b in
                            if a.isRead == b.isRead{
                                return a.createDate > b.createDate
                            }else{
                                return a.isRead
                            }
                        })
                    }
                    
                }
               
            }
            
        }
        
        return msgMap
        
    }
    
    
    func messageFilterData(_ result: Results<Message>)-> Results<Message>{
        if searchText == ""{
            return result
        }
        
        let resultFilter = result.filter(NSPredicate(format: "title CONTAINS[c] %@ OR body CONTAINS[c] %@", searchText, searchText))
        
        return resultFilter.sorted(by: [ SortDescriptor(keyPath: "isRead", ascending: true),SortDescriptor(keyPath: "createDate", ascending: false)])
    }
}







#Preview {
    NavigationStack{
        MessageView()
    }
    
}
