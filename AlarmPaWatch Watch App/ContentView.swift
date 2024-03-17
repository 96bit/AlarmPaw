//
//  ContentView.swift
//  AlarmPaWatch Watch App
//
//  Created by He Cho on 2024/2/4.
//

import SwiftUI

struct ContentView: View {
    @State var imageIndex = 0
    var body: some View {
        NavigationStack{
            List{
                
                VStack{
                    HStack{
                        Spacer()
                        Image(logoImage.arr[imageIndex].rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .animation(.bouncy, value: imageIndex)
                            .onTapGesture {
                                imageIndex = imageIndex < (logoImage.arr.count - 1) ? (imageIndex + 1) : 0
                            }
                        Spacer()
                    }
                    
                    HStack{
                        Spacer()
                        Text(NSLocalizedString("watchTips1", comment: "自由、简单、安全"))
                            .padding()
                        Spacer()
                       
                    }
                    HStack{
                        Spacer()
                        Button{
                            imageIndex = imageIndex < (logoImage.arr.count - 1) ? (imageIndex + 1) : 0
                        }label: {
                            Text(NSLocalizedString("watchBtn", comment: "图标"))
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
