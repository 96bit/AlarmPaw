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
//                
//                ToolbarItem(placement: .topBarLeading) {
//                    Button{
//                        Task(priority: .userInitiated) {
//                           await paw.registerAll()
//                        }
//                        self.toastText = NSLocalizedString("updateSuccess",comment: "")
//                    }label:{
//                        Image(systemName: "goforward")
//                            .tint(.green)
//                    }
//                }
                
            }
            .sheet(isPresented: $editMode, content: {
                NavigationStack{
                    addServerView()
                } .presentationDetents([.medium, .large])
            })
            .navigationTitle(NSLocalizedString("serverList",comment: ""))
            
        }
    }
 
}

extension ServerListView{
    private var serverList:some View{
        VStack{
            List{
                ForEach(paw.servers,id: \.id){item in
                    
                    Section(header:Text(item.status ? NSLocalizedString("online",comment: "") : NSLocalizedString("offline",comment: "")),footer:Text(NSLocalizedString("serverOnlineFooter",comment: ""))) {
                        HStack(alignment: .center){
                            Image(item.status ? "online": "offline")
                                .padding(.horizontal,5)
                            VStack{
                                HStack(alignment: .bottom){
                                    Text(NSLocalizedString("serverName",comment: "") + ":")
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
                                    self.toastText = NSLocalizedString("copySuccessText",comment: "")
                                    paw.copy(text: item.url + "/" + item.key)
                                }
                        }
                        .padding(.vertical,5)
                        
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button{
                                Task{
                                    await paw.register(server: item)
                                }
                                self.toastText = NSLocalizedString("controlSuccess",comment: "")
                            }label: {
                                Text(NSLocalizedString("registerAndCheck",comment: ""))
                            }.tint(.blue)
                        }
                        .swipeActions(edge: .leading) {
                            Button{
                                
                                if let index = paw.servers.firstIndex(where: {$0.id == item.id}){
                                    paw.servers[index].key = ""
                                }
                                
                                Task{
                                    await paw.register(server: item)
                                }
                                
                               
                                self.toastText = NSLocalizedString("controlSuccess",comment: "")
                            }label: {
                                Text(NSLocalizedString("resetKey",comment: "重置Key"))
                            }.tint(.red)
                        }
                        
                    }
                    
                    
                    
                    
                }.onDelete(perform: { indexSet in
                    if paw.servers.count > 1{
                        paw.servers.remove(atOffsets: indexSet)
                    }else{
                        self.toastText = NSLocalizedString("needOneServer",comment: "")
                    }
                    
                })
            }.toast(info: $toastText)
        }
    }
}



#Preview {
    NavigationStack{
        ServerListView().environmentObject(pawManager.shared)
    }
}
