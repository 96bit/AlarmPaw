//
//  ContentView.swift
//  AlarmPaWatch Watch App
//
//  Created by He Cho on 2024/2/4.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            List{
                
                VStack{
                    HStack{
                        Spacer()
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        Text(NSLocalizedString("watchTips1", comment: "免费、简单、安全"))
                            .padding()
                        Spacer()
                       
                    }
                    HStack{
                        Spacer()
                        Button{
                            
                        }label: {
                            Text(NSLocalizedString("watchBtn", comment: "打开即用"))
                        }.buttonStyle(.borderless)
                        Spacer()
                    }
                }.listRowBackground(Color.clear)
            }.navigationTitle(NSLocalizedString("CFBundleDisplayName", comment: "程序名"))
        }
    }
}

#Preview {
    ContentView()
}
