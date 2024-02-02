//
//  emailPageView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/2/1.
//

import SwiftUI
import SwiftSMTP

struct emailPageView: View {
    @EnvironmentObject var paw:pawManager
    @State var helpShow = false
    var body: some View {
        List{
            
            HStack{
                Spacer()
                Button{
                    sendMail(config: paw.email, title: "自动化: 测试", text: "{title:\"标题\",...}")
                }label: {
                    Text("测试")
                }
                .buttonStyle(BorderedButtonStyle())
                
                   
            }.listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section(header:Text("邮件服务器配置,本地化服务")) {
                HStack{
                    Text("Smtp:")
                        .foregroundStyle(.gray)
                    TextField("smtp.qq.com", text: $paw.email.smtp)
                        .textFieldStyle(.roundedBorder)
                       
                }
                HStack{
                    Text("Email:")
                        .foregroundStyle(.gray)
                    TextField("@twown.com", text: $paw.email.email)
                        .textFieldStyle(.roundedBorder)
                      
                }
                HStack{
                    Text("Password:")
                        .foregroundStyle(.gray)
                    SecureField("123", text: $paw.email.password)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            Section(header:Text("接收邮件列表")) {
                HStack{
                    Spacer()
                    Button{
                        paw.email.toEmail.insert(toEmailConfig(""), at: 0)
                    }label: {
                        Image(systemName: "plus.square.dashed")
                            .font(.headline)
                    }.buttonStyle(.borderless)
                }
                
                ForEach($paw.email.toEmail, id: \.id){item in
                    HStack{
                        Text("ToMail:")
                            .foregroundStyle(.gray)
                        TextField("@twown.com", text: item.mail)
                            .textFieldStyle(.roundedBorder)
                    }
                        
                }.onDelete(perform: { indexSet in
                    paw.email.toEmail.remove(atOffsets: indexSet)
                })
            }
            
           
            
            
        }.navigationTitle("邮件自动化")
            .toolbar {
                ToolbarItem {
                    Button{
                        self.helpShow.toggle()
                    }label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
            .fullScreenCover(isPresented: $helpShow) {
                SFSafariViewWrapper(url: URL(string: otherUrl.emailHelpUrl.rawValue)!)
                    .ignoresSafeArea()
            }
    }
    
}

#Preview {
    NavigationStack{
        emailPageView().environmentObject(pawManager.shared)
    }
}
