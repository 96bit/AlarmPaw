//
//  MessageItem.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/18.
//

import SwiftUI
import RealmSwift
import UIKit
import MarkdownUI

struct MessageItem: View {
    @ObservedRealmObject var message:NotificationMessage
    @EnvironmentObject var paw:pawManager
    @State private var toastText:String = ""
    @State private var showMark:Bool = false
    @State private var showAni:Bool = false
    var body: some View {
        Section {
            Grid{
                GridRow(alignment:.top ) {
                    VStack(spacing:10){
                        Group{
                            if let icon = message.icon,
                               let imageURL = URL(string: icon),
                               paw.startsWithHttpOrHttps(icon){
                                AsyncImageView(url: imageURL )
                            }else{
                                Image("slogo")
                                    .resizable()
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(alignment: .topTrailing) {
                            if let _ =  message.url {
                                Image(systemName: "link")
                                    .foregroundStyle(.green)
                                    .offset(x:5 , y: -5)
                            }
                        }
                        
                        Text( limitTextToLines(message.group ?? NSLocalizedString("unknown",comment: ""), charactersPerLine: 10)  )
                            .font(.system(size:10))
                            .foregroundStyle(message.isRead ? .gray : .red)
                            
                    }.onTapGesture {
                        if let url =  message.url{
                            let _ = RealmManager.shared.updateObject(message) { item2 in
                                item2.isRead = true
                            }
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
                            
                            Image(systemName: "bolt.horizontal.icloud.fill")
                                .foregroundStyle(message.cloud ? .green : .pink)
                                .font(.caption)
                            
                           
                        }
                       
                            
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                Image(systemName: showAni ? "text.badge.xmark" : "ellipsis")
                                    .foregroundStyle(.accent)
                                    .onTapGesture {
                                        self.showAni.toggle()
                                        if !showAni{
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                self.showMark.toggle()
                                            }
                                        }else{
                                            self.showMark.toggle()
                                        }
                                        let _ = RealmManager.shared.updateObject(message) { item2 in
                                            item2.isRead = true
                                        }
                                    }
                              
                            }
                        }.opacity(message.markdown != nil ? 1 : 0)
                    }
                }
                
               
                

                if let markdownText = message.markdown{
                    
                    
                    GridRow(alignment: .center) {
                        ScrollView {
                            Markdown(markdownText)
                        }
                       
                    }.gridCellColumns(2)
                    .frame(height: showMark ? 300 : 0)
                    .opacity(showAni ? 1 : 0)
                    .animation(.spring, value: showAni)

                   
                }
            }
            .toast(info: $toastText)
        }header: {
            HStack{
                
                Text(message.createDate.agoFormatString())
                    .font(.caption2)
                Spacer()
               
            }.frame(minHeight: 30)
            
        }.padding(.top)
        
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
        MessageItem(message: NotificationMessage(value: [ "id":"123","title":"123","isRead":true,"icon":"error","group":"123","image":"https://day.app/assets/images/avatar.jpg","body":"123","cloud":true]))
            .frame(width: 300)
            .environmentObject(pawManager.shared)
    }.listStyle(GroupedListStyle())
}
