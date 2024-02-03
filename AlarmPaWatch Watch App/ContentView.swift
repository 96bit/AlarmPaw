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
                        Text("免费、简单、安全")
                        Spacer()
                       
                    }
                    HStack{
                        Spacer()
                        Text("打开即用")
                        Spacer()
                    }
                }.listRowBackground(Color.clear)
            }.navigationTitle("PawPaw")
        }
    }
}

#Preview {
    ContentView()
}
