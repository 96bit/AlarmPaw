//
//  GroupMessageView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/2/17.
//

import SwiftUI
import RealmSwift

struct GroupMessageView: View {
    @ObservedResults(NotificationMessage.self,
                     sortDescriptor: SortDescriptor(keyPath: "createDate",
                                                    ascending: false)) var messages
    var msgMap:[String: Results<NotificationMessage>]{
        let results = filterMessage(messages, searchText: searchText)
        return createMessageMap(results)
    }
    @State private var expandedStates: [String: Bool] = [:]
    @State private var toastText:String = ""
    @Binding var searchText:String
    var body: some View {
        List{

            ForEach(msgMap.keys.sorted(), id: \.self) { key in
                
                Section{
                    NavigationLink {
                        if let messageResult = msgMap[key]{
                            List {
                                ForEach(messageResult, id: \.id) { message in
                                    MessageItem(message: message)
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            let _ = RealmManager.shared.updateObject(message) { item2 in
                                                item2.isRead = !item2.isRead
                                                self.toastText = NSLocalizedString("messageModeChanged",comment: "")
                                            }
                                        } label: {
                                            Label(message.isRead ? NSLocalizedString("markNotRead",comment: "") :  NSLocalizedString("markRead",comment: ""), systemImage: message.isRead ? "envelope.open": "envelope")
                                        }.tint(.blue)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            
                                            let _ = RealmManager.shared.deleteObject(message)
                                            
                                        } label: {
                                            Label(NSLocalizedString("deleteTitle",comment: ""), systemImage: "trash")
                                        }
                                    }
                                    .animation(.interactiveSpring, value: message.id)
                                    
                                }
                            }
                            .navigationTitle(key)
                           
                        }
                    } label: {
                        HStack{
                            Text(key)
                            Spacer()
                            let readCount = msgMap[key]?.where({!$0.isRead}).count ?? 0
                            Text(readCount == 0 ?NSLocalizedString("nothing",comment: "") : "\(readCount)")
                                .fontWeight(.bold)
                            Text(NSLocalizedString("notread",comment: ""))
                                .font(.system(size: 10))
                                .foregroundStyle(.gray)
                            
                        }
                    }
                }header: {
                    Text(String(format: NSLocalizedString("someMessageCount",comment: ""), msgMap[key]?.count ?? 0))
                }.swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        let realm = RealmManager.shared
                        let deleitem = realm.getObject()?.where({$0.group == key})
                        if let deleitem = deleitem{
                            let _ = realm.deleteObjects(deleitem)
                        }
                    } label: {
                        Label(NSLocalizedString("deleteMessageGroup",comment: ""), systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        let realm = RealmManager.shared
                        let alldata = realm.getObject()?.where({$0.group == key})
                        if let alldata = alldata{
                            let _ = realm.updateObjects(alldata) { data in
                                data?.isRead = true
                            }
                        }
                    } label: {
                        Label(NSLocalizedString("groupMarkRead",comment: ""), systemImage: "envelope")
                    }.tint(.blue)
                }
            
            }
        }
        .toast(info: $toastText)
        .listStyle(SidebarListStyle())
            
        
    }
    

    
}
extension GroupMessageView{
    func createMessageMap(_ messages:Results<NotificationMessage>) -> [String:Results<NotificationMessage>] {
        var msgMap:[String:Results<NotificationMessage>] = [:]
        
        for  message in messages{
            let group = message.group ??  NSLocalizedString("defultGroup",comment: "")
            if let _ = msgMap[group]{
                continue
            }else{
                
                let results = messages.where({$0.group == group})
                
                msgMap[group]  = results.sorted(by: [
                    SortDescriptor(keyPath: "isRead", ascending: true),
                    SortDescriptor(keyPath: "createDate", ascending: false)
                ])
               
            }
            
        }
        
        return msgMap
        
    }
}

#Preview {
    GroupMessageView(searchText: .constant(""))
}
