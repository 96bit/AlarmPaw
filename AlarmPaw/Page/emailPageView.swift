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
    @State var webUrl = "https://alarmpaw.twown.com/"
    var body: some View {
        List{

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
                SFSafariViewWrapper(url: URL(string: self.webUrl)!)
                    .ignoresSafeArea()
            }
    }
    
    
    func sendMail(){

        
        let smtp = SMTP(
            hostname: "smtp.qq.com",     // SMTP server address
            email: "909038822@qq.com",        // username to login
            password: "illozqrqvcshbahi"            // password to login
        )
        
        let drLight = Mail.User(name: "Dr. Light", email: "909038822@qq.com")
        let megaman = Mail.User(name: "Megaman", email: "rakeecao@icloud.com")

        let mail = Mail(
            from: drLight,
            to: [megaman],
            subject: "paw",
            text: "That was my ultimate wish."
        )

        smtp.send(mail) { (error) in
            if let error = error {
                print(error)
            }
        }
        
        
    }
}

#Preview {
    NavigationStack{
        emailPageView().environmentObject(pawManager.shared)
    }
}
