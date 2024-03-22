//
//  constant.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/3/22.
//

import Foundation


let defaultStore = UserDefaults(suiteName: settings.groupName)


struct otherUrl {
#if DEBUG
    static let defaultServer = "http://192.168.0.11:8080"
#else
    static let defaultServer = "https://push.twown.com"
#endif
    static let docServer = "https://alarmpaw.twown.com"
    static let defaultImage = docServer + "/_media/avatar.jpg"
    static let helpWebUrl = docServer + "/#/tutorial"
    static let problemWebUrl = docServer + "/#/faq"
    static let delpoydoc = docServer + "/#/?id=alarmpaw"
    static let emailHelpUrl = docServer + "/#/email"
    static let helpRegisterWebUrl = docServer + "/#/registerUser"
    static let actinsRunUrl = "https://github.com/96bit/AlarmPaw/actions/runs/"
}


struct settings {
    static let  groupName = "group.AlarmPaw"
    static let  realmName = "AlarmPaw.realm"
    static let  cloudMessageName = "alarmPawMessageCloud"
    static let  settingName = "cryptoSettingFields"
    static let  deviceToken = "deviceToken"
    static let  imageCache = "shard"
    static let  badgemode = "alarmpawbadgemode"
    static let  server = "serverArrayStroage"
    static let  defaultPage = "defaultPageViewShow"
    static let  messageFirstShow = "messageFirstShow"
    static let  messageShowMode = "messageShowMode"
    static let  syncServerUrl = "syncServerUrl"
    static let  syncServerParams = "syncServerParams"
    static let  emailConfig = "emailStmpConfig"
    static let  iCloudName = "iCloud.AlarmPaw"
    static let  firstStartApp = "firstStartApp"
    static let  CryptoSettingFields = "CryptoSettingFields"
}
