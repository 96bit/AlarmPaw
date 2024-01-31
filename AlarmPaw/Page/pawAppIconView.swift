//
//  pawAppIconView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/30.
//

import SwiftUI

struct pawAppIconView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("setting_active_app_icon") var setting_active_app_icon:appIcon = .def
    @State var toastText = ""
    var body: some View {
        List{
            ForEach(Array(logoImage.arr.enumerated()), id: \.offset){index,item in
                
                Button{
                    setting_active_app_icon = appIcon.arr[index]
                    let manager = UIApplication.shared
                    
                    var iconName:String? = manager.alternateIconName ?? appIcon.def.rawValue
                    
                    if setting_active_app_icon.rawValue == iconName{
                        return
                    }
                    
                    if setting_active_app_icon != .def{
                        iconName = setting_active_app_icon.rawValue
                    }else{
                        iconName = nil
                    }
                    if UIApplication.shared.supportsAlternateIcons {
                        Task{
                            do {
                                try await manager.setAlternateIconName(iconName)
                            }catch{
                                print(error)
                            }
                        }
                       
                    }else{
                        self.toastText = NSLocalizedString("switchError")
                    }
                    
                }label: {
                    HStack{
                        Image(item.rawValue)
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                            .frame(width: 60,height:60)
                            .tag(appIcon.arr[index])
                        Spacer()
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(.largeTitle))
                            .offset(x:appIcon.arr[index] == setting_active_app_icon ? 0 : 100)
                            .opacity(appIcon.arr[index] == setting_active_app_icon ? 1 : 0)
                            .foregroundStyle(.green)
                        
                    }.animation(.spring, value: setting_active_app_icon)
                        .listStyle(.plain)
                }
                
               
            }
        }
        .toast(info: $toastText)
        
        .listStyle(GroupedListStyle())
        .navigationTitle(NSLocalizedString("AppIconTitle"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem{
                Button{
                    self.dismiss()
                }label:{
                    Image(systemName: "xmark.seal")
                }
                
            }
        }
        
    }
}

#Preview {
    NavigationStack{
        pawAppIconView()
    }
    
}
