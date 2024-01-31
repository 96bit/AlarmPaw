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
    var logoArr = [logoImage.def,logoImage.zero,logoImage.one,logoImage.two,logoImage.three,logoImage.four,logoImage.five,logoImage.six,logoImage.seven]
    var iconArr = [appIcon.def,appIcon.zero,appIcon.one,appIcon.two,appIcon.three,appIcon.four,appIcon.five,appIcon.six,appIcon.seven]
    var body: some View {
        List{
            ForEach(Array(logoArr.enumerated()), id: \.offset){index,item in
                
                Button{
                    setting_active_app_icon = iconArr[index]
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
                        print("不能切换")
                    }
                    
                }label: {
                    HStack{
                       
                        Image(item.rawValue)
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                            .frame(width: 60,height:60)
                            .tag(iconArr[index])
                        Spacer()
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(.largeTitle))
                            .offset(x:iconArr[index] == setting_active_app_icon ? 0 : 100)
                            .opacity(iconArr[index] == setting_active_app_icon ? 1 : 0)
                            .foregroundStyle(.green)
                        
                    }.animation(.spring, value: setting_active_app_icon)
                        .listStyle(.plain)
                }
                
               
            }
        }
       
        .listStyle(GroupedListStyle())
        .navigationTitle("程序图标")
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
