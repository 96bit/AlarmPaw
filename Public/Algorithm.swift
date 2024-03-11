//
//  Algorithm.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/3/11.
//

import CryptoSwift
import Foundation
import SwiftUI


enum Algorithm: String, CaseIterable {
    case aes128 = "AES128"
    case aes192 = "AES192"
    case aes256 = "AES256"

    var modes: [String] {
        switch self {
        case .aes128, .aes192, .aes256:
            return ["CBC", "ECB", "GCM"]
        }
    }

    var paddings: [String] {
        switch self {
        case .aes128, .aes192, .aes256:
            return ["pkcs7"]
        }
    }

    var keyLength: Int {
        switch self {
        case .aes128:
            return 16
        case .aes192:
            return 24
        case .aes256:
            return 32
        }
    }
}

enum MyError: Error {
    case customError(description: String)
}

struct AESCryptoModel {
    let key: String
    let mode: BlockMode
    let padding: Padding
    let aes: AES
    
    
    init(cryptoFields: CryptoSettingFields) throws {
        
       
        guard let algorithm = Algorithm(rawValue: cryptoFields.algorithm) else {
            throw MyError.customError(description: "Invalid algorithm")
        }
        
        let key = cryptoFields.key
        if key == ""{
            throw MyError.customError(description: "Key is missing")
        }

        guard algorithm.keyLength == key.count else {
            throw MyError.customError(description: String(format: NSLocalizedString("enterKey", comment: ""), algorithm.keyLength))
        }
        

        var iv = ""
        if ["CBC", "GCM"].contains(cryptoFields.mode) {
            var expectIVLength = 0
            if cryptoFields.mode == "CBC" {
                expectIVLength = 16
            }
            else if cryptoFields.mode == "GCM" {
                expectIVLength = 12
            }

            let ivField = cryptoFields.iv
            
            if  ivField.count == expectIVLength {
                iv = ivField
            }
            else {
                throw MyError.customError(description: String(format: NSLocalizedString("enterIv", comment: ""), expectIVLength))
            }
        }

        let mode: BlockMode
        switch cryptoFields.mode {
        case "CBC":
            mode = CBC(iv: iv.bytes)
        case "ECB":
            mode = ECB()
        case "GCM":
            mode = GCM(iv: iv.bytes)
        default:
            throw MyError.customError(description: "Invalid Mode")
        }

        self.key = key
        self.mode = mode
        self.padding = Padding.pkcs7
        self.aes = try AES(key: key.bytes, blockMode: self.mode, padding: self.padding)
    }

    func encrypt(text: String) throws -> String {
        return try aes.encrypt(Array(text.utf8)).toBase64()
    }

    func decrypt(ciphertext: String) throws -> String {
        return String(data: Data(try aes.decrypt(Array(base64: ciphertext))), encoding: .utf8) ?? ""
    }
}


