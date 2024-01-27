//
//  Date+.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/16.
//

import UIKit

func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}


extension Date {
    func formatString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(for: self) ?? ""
    }

    func agoFormatString() -> String {
        let clendar = NSCalendar(calendarIdentifier: .gregorian)
        let cps = clendar?.components([.hour, .minute, .second, .day, .month, .year], from: self, to: Date(), options: .wrapComponents)

        let year = cps!.year!
        let month = cps!.month!
        let day = cps!.day!
        let hour = cps!.hour!
        let minute = cps!.minute!

        if year > 0 || month > 0 || day > 0 || hour > 12 {
            return formatString(format: "yyyy-MM-dd HH:mm")
        }
        if hour > 1 {
            return formatString(format: "HH:mm")
        }
        if hour > 0 {
            if minute > 0 {
                return String(format: NSLocalizedString("timeMinHourAgo"), hour, minute)
            }
            return String(format: NSLocalizedString("timeHourAgo"), hour)
        }
        if minute > 1 {
            return String(format: NSLocalizedString("timeMinAgo"), minute)
        }
        return NSLocalizedString("timeJustNow")
    }
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow: Date { return Date().dayAfter }
    static var lastHour: Date { return Calendar.current.date(byAdding: .hour, value: -1, to: Date())! }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }

    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }

    var noon: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
    func someDayBefore(_ day: Int)-> Date{
        return Calendar.current.date(byAdding: .day, value: -day, to: noon)!
    }
    
    func someHourBefore(_ hour:Int)-> Date{
        return Calendar.current.date(byAdding: .hour, value: -hour, to: Date())!
    }
}



enum MessageGroup:String{
    case group = "分组"
    case all = "全部"
}
enum mesAction: String{
    case markRead = "全部标为已读"
    case lastHour = "一小时前"
    case lastDay = "一天前"
    case lastWeek = "一周前"
    case lastMonth = "一月前"
    case allTime = "所有时间"
}

