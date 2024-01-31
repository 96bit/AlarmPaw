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
    @State var toastText:String = ""
    
    var tips:String{
          NSLocalizedString("syncTips")
    }
    var body: some View {
        List{
            
            Section{
                HStack(alignment: .center){
                    Spacer()
                    Button{
                        Task{
                            let res = await paw.syncClient()
                            paw.dispatch_sync_safely_main_queue {
                                
                                if res{
                                    self.toastText = NSLocalizedString("syncSuccess")
                                }else{
                                    self.toastText = NSLocalizedString("syncFail")
                                }
                              
                            }
                           
                        }
                       
                    }label: {
                        Text(NSLocalizedString("syncManualCall"))
                        
                    }.buttonStyle(.borderedProminent)
                }
            
            }.padding()
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

            
            Section (header: Text(NSLocalizedString("syncServerHeader")),footer: Text(paw.exampleUrl)){
                TextField(NSLocalizedString("syncServerField"), text: $paw.syncUrl)
                    .focused($urlFocus)
                    .background(urlFocus ? .gray : .clear)
                    .textFieldStyle(.roundedBorder)
                    .onAppear{
                        if !isValidURL(paw.syncUrl){
                            self.urlFocus.toggle()
                        }
                       
                    }
            }
            Section (header: Text(NSLocalizedString("syncParamsHeader")),footer:Text(NSLocalizedString("syncParamsFooter"))){
                TextField(NSLocalizedString("syncParamsTitle"), text: $paw.syncParams)
                    .focused($paramsFocus)
                    .textFieldStyle(.roundedBorder)
            }
           
            Section (footer: Text(tips)){ }
            
          
               
        }.navigationTitle(NSLocalizedString("syncTitle"))
        .toast(info: $toastText)
            
       
            
        
        
        
    }
}

#Preview {
    NavigationStack{
        syncRegisterView().environmentObject(pawManager.shared)
    }
    
}
