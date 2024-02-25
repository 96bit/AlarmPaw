//
//  other.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/22.
//

import Foundation
import SwiftSMTP

func startsWithHttpOrHttps(_ urlString: String) -> Bool {
    let pattern = "^(http|https)://.*"
    let test = NSPredicate(format:"SELF MATCHES %@", pattern)
    return test.evaluate(with: urlString)
}


func isValidURL(_ urlString: String) -> Bool {
    guard let url = URL(string: urlString) else {
        return false // 无效的URL格式
    }

    // 验证协议头是否是http或https
    guard let scheme = url.scheme, ["http", "https"].contains(scheme.lowercased()) else {
        return false
    }

    // 验证是否有足够的点分隔符
    let components = url.host?.components(separatedBy: ".")
    return components?.count ?? 0 >= 2
}


func sendMail(config:emailConfig,title:String,text:String){
    
    let smtp = SMTP(
        hostname: config.smtp,     // SMTP server address
        email: config.email,        // username to login
        password: config.password   // password to login
        // "illozqrqvcshbahi"
    )

    let mail = Mail(
        from: Mail.User(name: "AlarmPaw", email: "909038822@qq.com"),
        to: config.toEmail.map({Mail.User(name: "AlarmPaw", email: $0.mail)}),
        subject: title,
        text:text
    )

    smtp.send(mail) { (error) in
        if let error = error {
            print(error)
        }
    }
}


func sendMail(config:emailConfig,title:String,text:String, completionHandler: @escaping (Error?) -> Void){
    
    let smtp = SMTP(
        hostname: config.smtp,     // SMTP server address
        email: config.email,        // username to login
        password: config.password   // password to login
        // "illozqrqvcshbahi"
    )

    let mail = Mail(
        from: Mail.User(name: "AlarmPaw", email: "909038822@qq.com"),
        to: config.toEmail.map({Mail.User(name: "AlarmPaw", email: $0.mail)}),
        subject: title,
        text:text
    )
    
    smtp.send(mail) { (error) in
       completionHandler(error)
    }
    
}


func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return emailTest.evaluate(with: email)
}
