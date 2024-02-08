//
//  MessageItem.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/18.
//

import SwiftUI
import RealmSwift
import UIKit



struct MessageItem: View {
    @ObservedRealmObject var message:Message
//    @State var message:Message
    @EnvironmentObject var paw:pawManager
    @Binding var imageID:String
    @Binding var toastText:String
    var body: some View {
        Section {
            Grid{
                GridRow(alignment:.top ) {
                    VStack(spacing:10){
                        Group{
                            if let icon = message.icon{
                                if paw.startsWithHttpOrHttps(icon){
                                    if let imageURL = URL(string: icon){
                                        AsyncImageView(url: imageURL )
                                    }else{
                                        Image(msgIcon.info.rawValue)
                                            .resizable()
                                    }
                                }else{
                                    Image(getLocalIcon(iconStr: icon))
                                        .resizable()
                                }
                            }else{
                                Image(msgIcon.info.rawValue)
                                    .resizable()
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(alignment: .topTrailing) {
                            if let _ =  message.url {
                                Image(systemName: "cursorarrow.click.2")
                                    .background(Circle().foregroundStyle(.green))
                                    .offset(x:5 , y: -5)
                            }
                        }
                        
                        Text( limitTextToLines(message.group ?? NSLocalizedString("unknown"), charactersPerLine: 10)  )
                            .font(.system(size:10))
                            
                    }.onTapGesture {
                        if let url =  message.url{
                            paw.openUrl(url: url)
                        }
                       
                    }
                    ZStack(alignment: .topLeading){
                        VStack(alignment: .leading, spacing:10){
                            
                            if let title = message.title{
                                Text(title)
                                    .font(.system(.headline))
                            }
                            Divider()
                            if let body = message.body{
                                Text(body)
                            }
                        }.padding(.horizontal)
                        HStack{
                            Spacer()
                            Image(systemName: "bookmark")
                                .animation(.easeInOut, value: message.isRead)
                                .onTapGesture {
                                    let _ = RealmManager.shared.updateObject(message) { message in
                                        message.isRead = !message.isRead
                                        self.toastText = NSLocalizedString("typechanged")
                                    }
                                }
                                .onLongPressGesture{
                                    let messages = RealmManager.shared.getObject()
                                    let _ = RealmManager.shared.updateObjects(messages) { message in
                                        message?.isRead = true
                                    }
                                    self.toastText = NSLocalizedString("allRead")
                                }
                                .foregroundStyle(message.isRead ? .gray : .green)
                                .font(.caption)
                            
                        }
                    }
                }
                GridRow(alignment: .center) {
                    VStack(alignment: .leading, spacing:10){
                        
                        if let image =  message.image{
                            HStack{
                                Spacer()
                                Text( self.imageID == message.id ? NSLocalizedString("displayImage"):NSLocalizedString("showImage"))
                                    .font(.system(size: 10))
                            }.onTapGesture {
                                if self.imageID == message.id{
                                    self.imageID = "-1"
                                }else{
                                    self.imageID = message.id
                                }
                            }
                            if message.id == self.imageID{
                                Group{
                                    
                                    if let imageURL = URL(string: image){
                                        AsyncImageView(url: imageURL )
                                    }
                                }.aspectRatio(contentMode: .fit)
                                    .animation(.easeInOut, value: self.imageID)
                                
                            }
                            
                        }
                        
                    }.gridCellColumns(2)
                    
                }
                
               
            }
        }header: {
            HStack{
                if message.cloud {
                    Image(systemName: "bolt.horizontal.icloud.fill")
                        .foregroundStyle(Color("AccentColor"))
                        .font(.caption)
                }
                Text(message.createDate.agoFormatString())
                    .font(.caption2)
                Spacer()
               
            }.frame(minHeight: 30)
            
        }
        
    }
}

extension MessageItem{
    func getLocalIcon(iconStr:String)-> String {
        
        switch iconStr{
        case "weixin":
            return msgIcon.weixin.rawValue
        case "info":
            return msgIcon.info.rawValue
        case "warn":
            return msgIcon.warn.rawValue
        case "error":
            return msgIcon.error.rawValue
        case "miniapp":
            return msgIcon.miniapp.rawValue
        default:
            return msgIcon.info.rawValue
        }
        
    }

}

extension MessageItem{
    func limitTextToLines(_ text: String, charactersPerLine: Int) -> String {
            var result = ""
            var currentLineCount = 0

            for char in text {
                result.append(char)
                if char.isNewline || currentLineCount == charactersPerLine {
                    result.append("\n")
                    currentLineCount = 0
                } else {
                    currentLineCount += 1
                }
            }

            return result
        }
}



#Preview {
    List {
        MessageItem(message: Message(value: [ "id":"123","title":"123","isRead":true,"icon":"error","group":"123","image":"https://day.app/assets/images/avatar.jpg","body":"123","cloud":true]),imageID: .constant("123"),toastText: .constant("123"))
            .frame(width: 300)
            .environmentObject(pawManager.shared)
    }.listStyle(GroupedListStyle())
    
    
}
