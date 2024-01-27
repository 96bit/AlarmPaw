//
//  other.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/22.
//

import Foundation


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
