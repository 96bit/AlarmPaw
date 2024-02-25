//
//  SettingView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/16.
//

import SwiftUI
import RealmSwift
import CloudKit


struct SettingView: View {
    @ObservedResults(Message.self) var messages
    @EnvironmentObject var paw:pawManager
    @State private var isArchive:Bool = false
    @State private var webShow:Bool = false
    @State private var webUrl:String = otherUrl.helpWebUrl.rawValue
    @State private var progressValue: Double = 0.0
    @State private var showServer = false
    @State private var toastText = ""
    @State private var isShareSheetPresented = false
    @State private var jsonFileUrl:URL?
    @State private var cloudStatus = NSLocalizedString("checkimge",comment: "")
    @State private var serverSize:CGSize = .zero
    @State private var serverColor:Color = .red
    @State private var showChangeIcon = false
    @State private var showGithubAction = false
    @State private var showHelpWeb = false
    @State private var showProblemWeb = false
    var timerz = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
    var body: some View {
        
        VStack{
            List{
                if !paw.isNetworkAvailable{
                    Section(header:Text(
                        NSLocalizedString("settingNetWorkHeader",comment: "")
                    )) {
                        Button{
                            paw.openSetting()
                        }label: {
                            HStack{
                                Text(NSLocalizedString("settingNetWorkTitle",comment: ""))
                                    .foregroundStyle(Color("textBlack"))
                                Spacer()
                                Text(NSLocalizedString("openSetting",comment: ""))
                            }
                        }
                    }
                }
                
                if paw.notificationPermissionStatus.rawValue < 2 {
                    Section(header:Text(NSLocalizedString("notificationHeader",comment: ""))) {
                        Button{
                            if paw.notificationPermissionStatus.rawValue == 0{
                                paw.registerForRemoteNotifications()
                            }else{
                                paw.openSetting()
                            }
                        }label: {
                            HStack{
                                Text(NSLocalizedString("notificationTitle",comment: ""))
                                    .foregroundStyle(Color("textBlack"))
                                Spacer()
                                Text(paw.notificationPermissionStatus.rawValue == 0 ? NSLocalizedString("openNotification",comment: "") : NSLocalizedString("openSetting",comment: ""))
                            }
                        }
                    }
                }
                
                
                Section(header: Text("iCloud"),footer: Text(NSLocalizedString("icloudHeader",comment: ""))) {
                    NavigationLink(destination: {
                        cloudMessageView()
                    }, label: {
                        HStack{
                            Text(NSLocalizedString("icloudBody",comment: ""))
                            Spacer()
                            Text(cloudStatus)
                        }
                    })
                    .task{
                        let status = await CloudKitManager.shared.getCloudStatus()
                        paw.dispatch_sync_safely_main_queue {
                            self.cloudStatus = status
                        }
                    }
                }
                
                
                Section(header:Text(NSLocalizedString("mailHeader", comment: "邮件触发运行捷径"))) {
                    
                    NavigationLink(destination:  emailPageView()) {
                        HStack{
                            Text(NSLocalizedString("mailTitle", comment: "自动化配置"))
                            
                        }
                    }
                    
                    
                }
 
                Section(header: Text(NSLocalizedString("badgeHeader",comment: "")),footer: Text(NSLocalizedString("baddgeFooter",comment: ""))) {
                    HStack{
                        Text(NSLocalizedString("badgeModeTitle",comment: ""))
                            .foregroundStyle(Color("textBlack"))
                        Spacer()
                        Text(paw.badgeMode.rawValue)
                            .foregroundStyle(paw.badgeMode == .auto ? .blue : .red)
                    }.contentShape(Rectangle())
                        .onTapGesture {
                            paw.badgeMode = paw.badgeMode == .auto ? .custom : .auto
                            if let badge = RealmManager.shared.getUnreadCount(){
                                paw.changeBadge(badge:badge )
                            }
                            
                        }
                        .onLongPressGesture(minimumDuration: 1, maximumDistance: 10, perform: {
                            if paw.badgeMode == .auto{
                                self.toastText = NSLocalizedString("autoModeNotClear",comment: "")
                            }else{
                                self.toastText = NSLocalizedString("clearSuccess",comment: "")
                                paw.changeBadge(badge:-1)
                            }
                            
                        })
                }
                
                Section(footer:Text(NSLocalizedString("exportHeader",comment: ""))) {
                    HStack{
                        Button {
                            
                            if RealmManager.shared.getObject()?.count ?? 0 > 0{
                                self.toastText = NSLocalizedString("controlSuccess",comment: "")
                                // TODO: 这个位置有警告，暂时不清楚什么原因，不影响使用
                                self.exportJSON()
                                isShareSheetPresented = true
                            }else{
                                self.toastText = NSLocalizedString("nothingMessage",comment: "")
                            }
                            
                            
                        } label: {
                            Text(NSLocalizedString("exportTitle",comment: ""))
                        }
                        
                        Spacer()
                        Text(String(format: NSLocalizedString("someMessageCount",comment: ""), messages.count) )
                    }
                    
                }
                
                Section(footer:Text(NSLocalizedString("deviceTokenHeader",comment: ""))) {
                    Button{
                        if paw.deviceToken != ""{
                            paw.copy(text: paw.deviceToken)
                            self.toastText = NSLocalizedString("copySuccessText",comment: "")
                        }else{
                            self.toastText =  NSLocalizedString("needRegister",comment: "")
                        }
                    }label: {
                        HStack{
                            Text("DeviceToken")
                                .foregroundStyle(Color("textBlack"))
                            Spacer()
                            Text(maskString(paw.deviceToken))
                                .foregroundStyle(.gray)
                            Image(systemName: "doc.on.doc")
                        }
                    }
                }
                
                // MARK: GITHUB
                if let infoDict = Bundle.main.infoDictionary,
                   let runId = infoDict["GitHub Run Id"] as? String{
                    Section(footer:Text(NSLocalizedString("buildDesc",comment: ""))){
                        Button{
                            self.showGithubAction = true
                        }label:{
                            HStack{
                                Text("Github Run Id")
                                Spacer()
                                Text(runId)
                                    .foregroundStyle(.gray)
                                Image(systemName: "chevron.right")
                            }.foregroundStyle(Color("textBlack"))
                        }
                    }
                }
                
                
                Section(header:Text(NSLocalizedString("otherHeader",comment: ""))) {
                    
                    Button{
                        self.showChangeIcon.toggle()
                    }label: {
                        HStack(alignment:.center){
                            Text(NSLocalizedString("AppIconTitle",comment: "程序图标"))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }.foregroundStyle(Color("textBlack"))
                        
                    }
                    Button{
                        paw.openSetting()
                    }label: {
                        HStack(alignment:.center){
                            Text(NSLocalizedString("openSetting",comment: ""))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }.foregroundStyle(Color("textBlack"))
                        
                    }
                    
                    Button{
                        self.showProblemWeb.toggle()
                    }label: {
                        HStack(alignment:.center){
                            Text(NSLocalizedString("commonProblem",comment: ""))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }.foregroundStyle(Color("textBlack"))
                        
                    }
                    
                    Button{
                        self.showHelpWeb.toggle()
                    }label: {
                        HStack(alignment:.center){
                            Text(NSLocalizedString("useHelpTitle",comment: ""))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }.foregroundStyle(Color("textBlack"))
                        
                    }
                }
                
                
                
                
            }
            
        }
        .toast(info: $toastText)
        .background(hexColor("#f5f5f5"))
        .toolbar {
            ToolbarItem {
               
                Button{
                    self.showServer = true
                }label:{
                    Image("baseline_filter_drama_black_24pt")
                        .tint(serverColor)
                        .task {
                            let color = await paw.healthAllColor()
                            paw.dispatch_sync_safely_main_queue {
                                self.serverColor = color
                            }
                        }
                }
                .padding(.horizontal)
               
            }
        }
        .fullScreenCover(isPresented: $showProblemWeb) {
            SFSafariViewWrapper(url: URL(string: otherUrl.problemWebUrl.rawValue)!)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showHelpWeb) {
            SFSafariViewWrapper(url: URL(string: otherUrl.helpWebUrl.rawValue)!)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showGithubAction) {
            if let infoDict = Bundle.main.infoDictionary,
               let runId = infoDict["GitHub Run Id"] as? String{
                SFSafariViewWrapper(url: URL(string: otherUrl.actinsRunUrl.rawValue + runId)!)
                    .ignoresSafeArea()
            }
           
        }
        .fullScreenCover(isPresented: $showServer) {
            ServerListView()
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheet(activityItems: [self.jsonFileUrl!])
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showChangeIcon) {
            NavigationStack{
                pawAppIconView()
                
            }.presentationDetents([.medium])
            
        }
        .onReceive(self.timerz) { _ in
            Task{
                let color = await paw.healthAllColor()
                paw.dispatch_sync_safely_main_queue {
                    self.serverColor = color
                }
            }
        }
        
        
        
    }
    func maskString(_ str: String) -> String {
        guard str.count > 6 else {
            return str
        }
        
        let start = str.prefix(3)
        let end = str.suffix(4)
        let masked = String(repeating: "*", count: 5) // 固定为5个星号
        
        return start + masked + end
    }
}

extension SettingView{
    
    func exportJSON() {
        do {
            let msgs = Array(messages)
            let jsonData = try JSONEncoder().encode(msgs)
            
            guard let jsonString = String(data: jsonData, encoding: .utf8),
                  let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
                self.toastText = NSLocalizedString("exportFail",comment: "")
                return
            }
            
            let fileURL = documentsDirectory.appendingPathComponent("messages.json")
            try jsonString.write(to: fileURL, atomically: false, encoding: .utf8)
            self.jsonFileUrl = fileURL
            self.toastText = NSLocalizedString("exportSuccess",comment: "")
            print("JSON file saved at: \(fileURL.absoluteString)")
        } catch {
            self.toastText = NSLocalizedString("exportFail",comment: "")
            print("Error encoding JSON: \(error.localizedDescription)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Update the view controller if needed
    }
}




#Preview {
    NavigationStack{
        SettingView()
    }
}
