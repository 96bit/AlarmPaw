//
//  enumConst.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/16.
//

import Foundation
import SwiftUI




enum badgeAutoMode:String, CaseIterable {
    case auto = "Auto"
    case custom = "Custom"
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
    
    static let arr = [appIcon.def,appIcon.zero,appIcon.one,appIcon.two,appIcon.three,appIcon.four,appIcon.five,appIcon.six,appIcon.seven]
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
    static let arr = [logoImage.def,logoImage.zero,logoImage.one,logoImage.two,logoImage.three,logoImage.four,logoImage.five,logoImage.six,logoImage.seven]
}


enum saveType:String{
    case failUrl
    case failSave
    case failAuth
    case success
    case other
}

extension saveType {

    var localized: String {
        switch self {
        case .failUrl:
            return NSLocalizedString(self.rawValue, comment: "Url错误")
        case .failSave:
            return NSLocalizedString("failSave", comment: "Save failed")
        case .failAuth:
            return NSLocalizedString("failAuth", comment: "No permission")
        case .success:
            return NSLocalizedString("saveSuccess", comment: "Save successful")
        case .other:
            return NSLocalizedString("failOther", comment: "Other error")
        }
    }
}



