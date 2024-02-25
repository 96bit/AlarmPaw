//
//  AllMessageView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/2/17.
//

import SwiftUI
import RealmSwift

struct AllMessageView: View {
    @Binding var searchText:String
    @ObservedResults(Message.self,
                     sortDescriptor: SortDescriptor(keyPath: "createDate",
                                                    ascending: false)) var messages
    var messageResults:Results<Message> {
       return filterMessage(messages, searchText: searchText)
    }
    
    @State var toastText:String = ""
    var body: some View {
        List{
            ForEach(messageResults, id: \.id) { item in
                
                MessageItem(message: item)
                    .swipeActions(edge: .leading) {
                        Button {
                            let _ = RealmManager.shared.updateObject(item) { item2 in
                                item2.isRead = !item2.isRead
                                self.toastText = NSLocalizedString("messageModeChanged",comment: "")
                            }
                        } label: {
                            Label(item.isRead ? NSLocalizedString("markNotRead",comment: "") :  NSLocalizedString("markRead",comment: ""), systemImage: item.isRead ? "envelope.open": "envelope")
                        }.tint(.blue)
                    }
                    .animation(.interactiveSpring, value: item.id)
            }.onDelete(perform: $messages.remove)
        }.toast(info: $toastText)
    }
}

#Preview {
    AllMessageView(searchText: .constant(""))
}
