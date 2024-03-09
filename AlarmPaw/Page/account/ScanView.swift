//
//  ScanView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/2/25.
//

import SwiftUI
import AVFoundation

struct ScanView: View {
    @Environment(\.dismiss) var dismiss
    @State private var torchIsOn = false
    @State private var restart = false
    @State private var scanCode = ""
    @State private var showActive = false
    var startConfig: (String, Int)->Void
    var body: some View {
        ZStack{
            QRScannerSampleView(restart: $restart,flash: $torchIsOn,value: $scanCode)
                .onChange(of: scanCode) { value in
                    debugPrint(scanCode)
                    let (mode, url) = scanModeAndString(scanCode)
                    switch mode {
                    case "add":
                        startConfig(url,0)
                        self.dismiss()
                    case "config":
                        startConfig(url,1)
                        self.dismiss()
                    default:
                        self.showActive.toggle()
                    }
                    
                   
                }
                .actionSheet(isPresented: $showActive) {
                    
                    ActionSheet(title: Text("不正确的地址"),buttons: [

                        .default(Text("重新扫码"), action: {
                            debugPrint(self.scanCode)
                            self.scanCode = ""
                            self.restart.toggle()
                            self.showActive.toggle()
                        }),
                        
                        .cancel({
                            self.dismiss()
                        })
                    ])
                }
           
            
                
            VStack{
                HStack{
                    Button{
                        self.torchIsOn.toggle()
                    }label: {
                        Image(systemName: "flashlight.\(torchIsOn ? "on" : "off").circle")
                            .font(.largeTitle)
                            .padding(.top, 8)
                    }
                    Spacer()
                    CloseButton()
                        .onTapGesture {
                            self.dismiss()
                        }
                        
                }
                .padding()
                .padding(.top,50)
                Spacer()
                VStack{
                    Text("config:https://twown.com/config")
                    
                    Text("OR")
                    Text("add:https://push.twown.com")
                }.padding(.bottom, 50)
                    .foregroundStyle(.gray)
                
            }
            
        }.ignoresSafeArea()
    }
    

}

#Preview {
    ScanView { _,_ in
        
    }
}
