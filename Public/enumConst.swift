//
//  enumConst.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/16.
//

import Foundation
import SwiftUI


enum settings :String{
    case groupName = "group.AlarmPaw"
    case realmName = "AlarmPaw.realm"
    case cloudMessageName = "alarmPawMessageCloud"
    case settingName = "cryptoSettingFields"
    case deviceToken = "deviceToken"
    case imageCache = "shard"
    case badgemode = "alarmpawbadgemode"
    case server = "serverArrayStroage"
    case defaultPage = "defaultPageViewShow"
    case messageFirstShow = "messageFirstShow"
    case messageShowMode = "messageShowMode"
    case syncServerUrl = "syncServerUrl"
    case syncServerParams = "syncServerParams"
    case emailConfig = "emailStmpConfig"
    case iCloudName = "iCloud.AlarmPaw"
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
    case defaultImage = "https://alarmpaw.twown.com/_media/avatar.jpg"
    case helpWebUrl = "https://alarmpaw.twown.com/#/tutorial"
    case problemWebUrl = "https://alarmpaw.twown.com/#/faq"
    case defaultServer = "https://push.twown.com"
    case delpoydoc = "https://alarmpaw.twown.com/#/?id=alarmpaw"
    case emailHelpUrl = "https://alarmpaw.twown.com/#/email"
}


enum appIcon:String,CaseIterable{
    case def = "AppIcon"
    case zero = "AppIcon0"
    case one = "AppIcon1"
    case two = "AppIcon2"
    case three = "AppIcon3"
    case four = "AppIcon4"
    case five = "AppIcon5"
    case six = "AppIcon6"
    case seven = "AppIcon7"
    case eight = "AppIcon8"
    case nine = "AppIcon9"
    
    static let arr = [appIcon.def,appIcon.zero,appIcon.one,appIcon.two,appIcon.three,appIcon.four,appIcon.five,appIcon.six,appIcon.seven,appIcon.eight,appIcon.nine]
}


enum logoImage:String,CaseIterable{
    case def = "logo"
    case zero = "logo0"
    case one = "logo1"
    case two = "logo2"
    case three = "logo3"
    case four = "logo4"
    case five = "logo5"
    case six = "logo6"
    case seven = "logo7"
    case eight = "logo8"
    case nine = "logo9"
    static let arr = [logoImage.def,logoImage.zero,logoImage.one,logoImage.two,logoImage.three,logoImage.four,logoImage.five,logoImage.six,logoImage.seven,logoImage.eight,logoImage.nine]
}
