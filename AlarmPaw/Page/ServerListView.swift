//
//  ServerListView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/18.
//

import SwiftUI

struct ServerListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var paw:pawManager
    @State var showAction:Bool = false
    @State var toastText:String = ""
    @State var editMode:Bool = false
    var body: some View {
        NavigationStack{
            serverList
            .toolbar{
                ToolbarItem {
                    Button{
                        self.editMode.toggle()
                    }label:{
                        Image(systemName: "plus")
                            .tint(Color("textBlack"))
                    }
                    .padding(.horizontal)
                }
                ToolbarItem{
                    Button{
                        dismiss()
                    }label: {
                        Image(systemName: "xmark.seal")
                            .foregroundStyle(Color.gray)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        paw.registerAll()
                        self.toastText = NSLocalizedString("updateSuccess")
                    }label:{
                        Image(systemName: "goforward")
                            .tint(.green)
                    }
                }
                
            }
            .sheet(isPresented: $editMode, content: {
                NavigationStack{
                    addServerView()
                } .presentationDetents([.medium, .large])
            })
            .navigationTitle(NSLocalizedString("serverList"))
            
        }
    }
 
}

extension ServerListView{
    private var serverList:some View{
        VStack{
            List{
                ForEach(paw.servers,id: \.id){item in
                    
                    Section(header:Text(item.status ? NSLocalizedString("online") : NSLocalizedString("offline")),footer:Text(NSLocalizedString("serverOnlineFooter"))) {
                        HStack(alignment: .center){
                            Image(item.status ? "online": "offline")
                                .padding(.horizontal,5)
                            VStack{
                                HStack(alignment: .bottom){
                                    Text(NSLocalizedString("serverName") + ":")
                                        .font(.system(size: 10))
                                        .frame(width:40)
                                    Text(item.name)
                                        .font(.headline)
                                    Spacer()
                                }
                                
                                HStack(alignment: .bottom){
                                    Text("KEY:")
                                        .frame(width:40)
                                    Text(item.key)
                                    Spacer()
                                } .font(.system(size: 10))
                                
                            }
                            Spacer()
                            Image(systemName: "doc.on.doc")
                                .onTapGesture{
                                    self.toastText = NSLocalizedString("copySuccessText")
                                    paw.copy(text: item.url + "/" + item.key)
                                }
                        }
                        .padding(.vertical,5)
                        
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button{
                                paw.register(server: item)
                                self.toastText = NSLocalizedString("controlSuccess")
                            }label: {
                                Text(NSLocalizedString("registerAndCheck"))
                            }.tint(.blue)
                        }
                        
                    }
                    
                    
                    
                    
                }.onDelete(perform: { indexSet in
                    if paw.servers.count > 1{
                        paw.servers.remove(atOffsets: indexSet)
                    }else{
                        self.toastText = NSLocalizedString("needOneServer")
                    }
                    
                })
            }.toast(info: $toastText)
        }
    }
}


//
//#Preview {
//    NavigationStack{
//        ServerListView().environmentObject(pawManager.shared)
//    }
//}
