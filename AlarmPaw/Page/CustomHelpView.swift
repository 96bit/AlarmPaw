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
                    Picker(selection: $pickerSeletion, label: Text(NSLocalizedString("changeServer"))) {
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
            .navigationTitle(NSLocalizedString("useExample"))
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
        
        pushExample(header: NSLocalizedString("pushExampleHeader1"), footer: NSLocalizedString("pushExampleFooter1"), title: NSLocalizedString("pushExampleTitle1"),params: NSLocalizedString("pushExampleParams1")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader2"), footer: NSLocalizedString("pushExampleFooter2"), title: NSLocalizedString("pushExampleTitle2"),params: NSLocalizedString("pushExampleParams2")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader3"), footer: NSLocalizedString("pushExampleFooter3"), title: NSLocalizedString("pushExampleTitle3"),params: NSLocalizedString("pushExampleParams3")),
        
        
        pushExample(header: NSLocalizedString("pushExampleHeader4"), footer: NSLocalizedString("pushExampleFooter4"), title: NSLocalizedString("pushExampleTitle4"),params: NSLocalizedString("pushExampleParams4")),
        
        
        pushExample(header: NSLocalizedString("pushExampleHeader5"), footer: NSLocalizedString("pushExampleFooter5"), title: NSLocalizedString("pushExampleTitle5"),params: NSLocalizedString("pushExampleParams5")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader6"), footer: NSLocalizedString("pushExampleFooter6"), title: NSLocalizedString("pushExampleTitle6"),params: NSLocalizedString("pushExampleParams6")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader7"), footer: NSLocalizedString("pushExampleFooter7"), title: NSLocalizedString("pushExampleTitle7"),params: NSLocalizedString("pushExampleParams7") ),
        
        pushExample(header: NSLocalizedString("pushExampleHeader8"), footer: NSLocalizedString("pushExampleFooter8"), title: NSLocalizedString("pushExampleTitle8"),params: NSLocalizedString("pushExampleParams8")),
        
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
                            self.toastText = NSLocalizedString("copySuccessText")
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
                                        self.toastText = NSLocalizedString("offline")
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
