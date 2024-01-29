//
//  MessageModal.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/13.
//

import SwiftUI
import RealmSwift
import Foundation
import CloudKit
import UIKit


final class Message: Object , ObjectKeyIdentifiable{
    @Persisted var id:String = UUID().uuidString
    @Persisted var title:String?
    @Persisted var body:String?
    @Persisted var image:String?
    @Persisted var icon:String?
    @Persisted var group:String?
    @Persisted var createDate = Date()
    @Persisted var isRead:Bool = false
    @Persisted var url:String?
}

extension Message: Codable{
    enum CodingKeys: String, CodingKey {
        case id, title, body, image, icon, group, createDate, isRead, url
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(icon, forKey: .icon)
        try container.encodeIfPresent(group, forKey: .group)
        try container.encodeIfPresent(isRead, forKey: .isRead)
        try container.encodeIfPresent(url, forKey: .url)
    }
}


extension Message{
    static let messages = [
       
        Message(value: ["title":  NSLocalizedString("messageExampleTitle1",comment: ""),"group":  NSLocalizedString("messageExampleGroup1",comment: ""),"body": NSLocalizedString("messageExampleBody1",comment: ""),"icon":"warn","image":otherUrl.defaultImage.rawValue]),
        Message(value: ["title":NSLocalizedString("messageExampleTitle2",comment: ""),"group":NSLocalizedString("messageExampleGroup2",comment: ""),"body":NSLocalizedString("messageExampleBody2",comment: ""),"icon":otherUrl.defaultImage.rawValue]),
        Message(value: ["group":NSLocalizedString("messageExampleGroup3",comment: ""),"title":NSLocalizedString("messageExampleTitle3",comment: "") ,"body":NSLocalizedString("messageExampleBody3",comment: ""),"url":"weixin://","icon":"weixin"])
    ]
}




