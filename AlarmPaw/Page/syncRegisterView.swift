//
//  syncRegisterView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/26.
//

import SwiftUI

struct syncRegisterView: View {
    @State var address:String = ""
    @FocusState var urlFocus
    @State var httpHeader = 1
    var body: some View {
        VStack(alignment: .leading){

            Section (header: Text("请求地址"),footer:Text("例如：https://twown.com/sync")){
                LabeledContent{
                    TextField("输入地址", text: $address)
                        .focused($urlFocus)
                }label: {
                    Picker(selection: $httpHeader, label: Text("Picker")) {
                        Text("http://").tag(1)
                        Text("https://").tag(2)
                    }.frame(minWidth: 100)
                }
               
                Divider()
            }
           
            
        }.navigationTitle("同步注册")
        
    }
}

#Preview {
    NavigationStack{
        syncRegisterView()
    }
    
}
