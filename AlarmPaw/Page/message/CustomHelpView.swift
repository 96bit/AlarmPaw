//
//  CustomHelpView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/17.
//

import SwiftUI
import UIKit

struct CustomHelpView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var phase
    @EnvironmentObject var paw:pawManager
    @State var username:String = ""
    @State var title:String = ""
    @State  var pickerSeletion:Int = 0
    @State var toastText = ""
    @State private var showAlart = false
    var body: some View {
        NavigationStack{

            List{
                
                HStack{
                    Spacer()
                    Picker(selection: $pickerSeletion, label: Text(NSLocalizedString("changeServer",comment: ""))) {
                        ForEach(paw.servers.indices, id: \.self){index in
                            let server = paw.servers[index]
                            Text(server.name).tag(server.id)
                        }
                    }.pickerStyle(MenuPickerStyle())
                       
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
                customHelpItemView
               
                
            }.listStyle(GroupedListStyle())
            .navigationTitle(NSLocalizedString("useExample",comment: ""))
                .toolbar{
                    ToolbarItem {
                        NavigationLink{
                            musicView()
                        }label: {
                            Image(systemName: "headphones.circle")
                                .foregroundStyle(Color.gray)
                        }
                    }
                    
                    
                    ToolbarItem{
                        Button{
                            dismiss()
                        }label: {
                            Image(systemName: "xmark.seal")
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                .toast(info: $toastText)
        }
    }
}



#Preview {
    
    CustomHelpView().environmentObject(pawManager.shared)
    
}



struct pushExample {
    var id = UUID()
    var header,footer,title,params:String
    static let datas:[pushExample] = [
        
        pushExample(header: NSLocalizedString("pushExampleHeader1",comment: ""), footer: NSLocalizedString("pushExampleFooter1",comment: ""), title: NSLocalizedString("pushExampleTitle1",comment: ""),params: NSLocalizedString("pushExampleParams1",comment: "")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader2",comment: ""), footer: NSLocalizedString("pushExampleFooter2",comment: ""), title: NSLocalizedString("pushExampleTitle2",comment: ""),params: NSLocalizedString("pushExampleParams2",comment: "")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader3",comment: ""), footer: NSLocalizedString("pushExampleFooter3",comment: ""), title: NSLocalizedString("pushExampleTitle3",comment: ""),params: NSLocalizedString("pushExampleParams3",comment: "")),
        
        
        pushExample(header: NSLocalizedString("pushExampleHeader4",comment: ""), footer: NSLocalizedString("pushExampleFooter4",comment: ""), title: NSLocalizedString("pushExampleTitle4",comment: ""),params: NSLocalizedString("pushExampleParams4",comment: "")),
        
        
        pushExample(header: NSLocalizedString("pushExampleHeader5",comment: ""), footer: NSLocalizedString("pushExampleFooter5",comment: ""), title: NSLocalizedString("pushExampleTitle5",comment: ""),params: NSLocalizedString("pushExampleParams5",comment: "")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader6",comment: ""), footer: NSLocalizedString("pushExampleFooter6",comment: ""), title: NSLocalizedString("pushExampleTitle6",comment: ""),params: NSLocalizedString("pushExampleParams6",comment: "")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader7",comment: ""), footer: NSLocalizedString("pushExampleFooter7",comment: ""), title: NSLocalizedString("pushExampleTitle7",comment: ""),params: NSLocalizedString("pushExampleParams7",comment: "") ),
        
        pushExample(header: NSLocalizedString("pushExampleHeader8",comment: ""), footer: NSLocalizedString("pushExampleFooter8",comment: ""), title: NSLocalizedString("pushExampleTitle8",comment: ""),params: NSLocalizedString("pushExampleParams8",comment: "")),
        
    ]
}

extension CustomHelpView{
    private var customHelpItemView:some View{
       
        ForEach(pushExample.datas,id: \.id){ item in
            let resultUrl = paw.servers[pickerSeletion].url + "/" + paw.servers[pickerSeletion].key + "/" + item.params
            Section(
                header:Text(item.header),
                footer: Text(item.footer)
            ) {
                HStack{
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "doc.on.doc")
                        .padding(.horizontal)
                        .onTapGesture {
                            UIPasteboard.general.string = resultUrl
                            self.toastText = NSLocalizedString("copySuccessText",comment: "")
                        }
                    Image(systemName: "safari")
                        .onTapGesture {
                            Task{
                                let ok =  await  paw.health(url: paw.servers[pickerSeletion].url + "/health" )
                                paw.dispatch_sync_safely_main_queue {
                                    if ok{
                                        if let url = URL(string: resultUrl){
                                            UIApplication.shared.open(url)
                                        }
                                    }else{
                                        self.toastText = NSLocalizedString("offline",comment: "")
                                    }
                                }
                            }
                            
                        }
                }
                Text(resultUrl).font(.caption)
            }
        }
       
    }
}
