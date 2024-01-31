//
//  syncRegisterView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/26.
//

import SwiftUI

struct syncRegisterView: View {
    @EnvironmentObject var paw:pawManager
   
    @FocusState var urlFocus
    @FocusState var paramsFocus
    @State var httpHeader = 1
    
    
    var tips:String{
            """
        本功能会在注册完设备后异步调用该api，传输所有服务器的资料(程序不会校验是否发送成功)
        最后的请求地址示例如下:
        https://twown.com/sync?custom=自定义内容&servers=[{"url":"https://push.twown.com",“key”:"123123123123123"},...]
        """
    }
    var body: some View {
        List{
            
            Section{
                HStack(alignment: .center){
                    Spacer()
                    Button{
                        
                    }label: {
                        Text("手动调用")
                        
                    }.buttonStyle(.borderedProminent)
                }
            
            }.padding()
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

            
            Section (header: Text("服务器地址"),footer: Text(paw.exampleUrl)){
                TextField("输入地址", text: $paw.syncUrl)
                    .focused($urlFocus)
                    .background(urlFocus ? .gray : .clear)
                    .textFieldStyle(.roundedBorder)
                    .onAppear{
                        self.urlFocus.toggle()
                    }
            }
            Section (header: Text("输入自定义字段的内容"),footer:Text("自定义字段会放在url后面接?custom=内容")){
                TextField("输入自定义字段的内容", text: $paw.syncParams)
                    .focused($paramsFocus)
                    .textFieldStyle(.roundedBorder)
            }
           
            Section (footer: Text(tips)){ }
            
          
               
        }.navigationTitle("同步回调")
            
       
            
        
        
        
    }
}

#Preview {
    NavigationStack{
        syncRegisterView().environmentObject(pawManager.shared)
    }
    
}
