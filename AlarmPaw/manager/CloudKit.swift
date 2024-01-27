//
//  CloudKit.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/17.
//

import CloudKit

class CloudKitManager {
    static let shared = CloudKitManager()
    
    private let database: CKDatabase
    
    private init() {
        database = CKContainer.default().publicCloudDatabase
    }
    
    // 保存数据
    func save(recordType: String, data: [String: Any], completion: @escaping (Result<CKRecord, Error>) -> Void) {
        let newRecord = CKRecord(recordType: recordType)
        
        data.forEach { newRecord[$0.key] = $0.value as? CKRecordValue }
        
        database.save(newRecord) { record, error in
            if let record = record {
                completion(.success(record))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    // 查询数据
    func query(recordType: String, predicate: NSPredicate = NSPredicate(value: true), desiredKeys: [String]? = nil, resultsLimit: Int = CKQueryOperation.maximumResults, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = desiredKeys
        operation.resultsLimit = resultsLimit
        
        var fetchedRecords = [CKRecord]()
        
        operation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                fetchedRecords.append(record)
            case .failure(let error):
                print("Error fetching record: \(recordID) - \(error)")
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(_):
                completion(.success(fetchedRecords))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        database.add(operation)
    }
}
