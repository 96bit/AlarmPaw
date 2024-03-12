//
//  URLSession+.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/14.
//

import Foundation

extension URLSession{
    enum APIError:Error{
        case invalidURL
        case invalidCode(Int)
    }
    
    
    func data(for urlRequest:URLRequest) async throws -> Data{
        let (data,response) = try await self.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else{ throw APIError.invalidURL }
        guard 200...299 ~= response.statusCode else {throw APIError.invalidCode(response.statusCode) }
        return data
    }
    
    
    
  
}

extension URLSession {
    static let imageSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = .imageCache
        
        return .init(configuration: config)
    }()
}

extension URLCache {
    static let imageCache: URLCache = {
        .init(memoryCapacity: 20 * 1024 * 1024,
              diskCapacity: 30 * 1024 * 1024)
    }()
}

extension URLComponents{
    func getParams()-> [String:String]{
        var parameters = [String: String]()
        // 遍历查询项目并将它们添加到字典中
        if let queryItems = self.queryItems {
         
            for queryItem in queryItems {
                if let value = queryItem.value {
                    parameters[queryItem.name] = value
                }
            }
        }
        return parameters
    }
}
