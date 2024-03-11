//
//  otherModal.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/23.
//

import Foundation




struct serverInfo: Codable, Identifiable{
    var id:UUID = UUID()
    var url:String
    var key:String
    var status:Bool = false
    
    var name:String{
        var name = url
        if let range = url.range(of: "://") {
           name.removeSubrange(url.startIndex..<range.upperBound)
        }
        return name
    }
    
    enum CodingKeys: CodingKey {
        case id
        case url
        case key
        case status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.url = try container.decode(String.self, forKey: .url)
        self.key = try container.decode(String.self, forKey: .key)
        self.status = try container.decode(Bool.self, forKey: .status)
    }
    
    init(url:String, key: String,statues:Bool = false){
        self.url = url
        self.key = key
        self.status = statues
    }
    
    static let serverDefault = serverInfo(url: otherUrl.defaultServer.rawValue, key: "")
  
}



struct toEmailConfig :Codable{
    var id:UUID = UUID()
    var mail:String
    enum CodingKeys: CodingKey {
        case id
        case mail
    }
    
    init(_ mail:String){
        self.mail = mail
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.mail = try container.decode(String.self, forKey: .mail)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.mail, forKey: .mail)
    }
}





struct emailConfig: Codable{
    var smtp:String
    var email:String
    var password:String
    var toEmail:[toEmailConfig]
    
    
    init(smtp: String, email: String, paswsword: String, toEmail: [toEmailConfig]) {
        self.smtp = smtp
        self.email = email
        self.password = paswsword
        self.toEmail = toEmail
    }
    
    enum CodingKeys: CodingKey {
        case smtp
        case email
        case password
        case toEmail
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.smtp = try container.decode(String.self, forKey: .smtp)
        self.email = try container.decode(String.self, forKey: .email)
        self.password = try container.decode(String.self, forKey: .password)
        self.toEmail = try container.decode([toEmailConfig].self, forKey: .toEmail)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.smtp, forKey: .smtp)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.password, forKey: .password)
        try container.encode(self.toEmail, forKey: .toEmail)
    }
    

   static let data = emailConfig(smtp: "smtp.qq.com", email: "xxxxx@qq.com", paswsword: "123123", toEmail: [toEmailConfig("paw@twown.com")])
    
}


extension emailConfig: RawRepresentable{
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8) ,
              let result = try? JSONDecoder().decode(
                Self.self,from: data) else{
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let result = try? JSONEncoder().encode(self),
              let string = String(data: result, encoding: .utf8) else{
            return ""
        }
        return string
    }
}


struct CryptoSettingFields: Codable,Equatable {
    var algorithm: String
    var mode: String
    var padding: String
    var key: String
    var iv: String
    
    
    init(algorithm: String, mode: String, padding: String, key: String, iv: String) {
        self.algorithm = algorithm
        self.mode = mode
        self.padding = padding
        self.key = key
        self.iv = iv
    }
    
    enum CodingKeys: CodingKey {
        case algorithm
        case mode
        case padding
        case key
        case iv
    }
    

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.algorithm = try container.decode(String.self, forKey: .algorithm)
        self.mode = try container.decode(String.self, forKey: .mode)
        self.padding = try container.decode(String.self, forKey: .padding)
        self.key = try container.decode(String.self, forKey: .key)
        self.iv = try container.decode(String.self, forKey: .iv)
    }
    
   
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.algorithm, forKey: .algorithm)
        try container.encode(self.mode, forKey: .mode)
        try container.encode(self.padding, forKey: .padding)
        try container.encode(self.key, forKey: .key)
        try container.encode(self.iv, forKey: .iv)
    }
    
    
    static let data = CryptoSettingFields(algorithm: "AES128", mode: "CBC", padding: "pkcs7", key: "",iv: "")
}

extension CryptoSettingFields: RawRepresentable{
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8) ,
              let result = try? JSONDecoder().decode(
                Self.self,from: data) else{
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let result = try? JSONEncoder().encode(self),
              let string = String(data: result, encoding: .utf8) else{
            return ""
        }
        return string
    }
}
