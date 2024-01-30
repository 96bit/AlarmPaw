//
//  enumConst.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/16.
//

import Foundation



enum settings :String{
    case groupName = "group.AlarmPaw"
    case realmName = "AlarmPaw.realm"
    case cloudMessageName = "alarmPawMessageCloud"
    case settingName = "cryptoSettingFields"
    case deviceToken = "deviceToken"
    case deviceKey = "deviceKey"
    case pawKey = "pawKey"
    case imageCache = "shard"
    case badgemode = "alarmpawbadgemode"
    case server = "serverArrayStroage"
    case defaultPage = "defaultPageViewShow"
    case messageFirstShow = "messageFirstShow"
    case messageShowMode = "messageShowMode"
}


enum badgeAutoMode:String {
    case auto = "自动"
    case custom = "自定义"
}


enum msgIcon: String, Codable{
    case info = "icon-info"
    case warn = "icon-warn"
    case error = "icon-error"
    case weixin = "icon-weixin"
    case miniapp = "icon-miniapp"
    
}

enum otherUrl:String{
    case defaultImage = "https://day.app/assets/images/avatar.jpg"
    case helpWebUrl = "https://bark.day.app/#/?id=bark"
    case problemWebUrl = "https://bark.day.app/#/faq"
    case defaultServer = "https://push.shkqg.com"
    case delpoydoc = "https://docs.twown.com/docs/alarm/alarmpaw/"
}
