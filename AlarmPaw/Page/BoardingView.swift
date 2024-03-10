//
//  BoardingView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/3/10.
//

import SwiftUI

struct BoardingView: View {
    @State var selectPage:Int = 1
    var pages = [
    pageView(title: "初始化网络", imageName: "notnet"),
    pageView(title: "初始化通知", imageName: "openno"),
    
    ]
    var body: some View {
        TabView(selection: $selectPage) {
            ForEach(pages, id: \.id){item in
                VStack{
                    Spacer()
                    Image(item.imageName)
                        .clipShape(Circle())
                    Spacer()
                        
                   
                    Button {
                        
                    } label: {
                        Text(item.title)
                    }.padding(.bottom, 50)
                   
                   
                }
                .tag(1)
                
                
            }
            
          
           
        }.ignoresSafeArea()
            .tabViewStyle(.page)
    }
    
    struct pageView:Equatable {
        var id:String = UUID().uuidString
        var title:String
        var imageName:String
    }
    
    
}

#Preview {
    BoardingView()
}
