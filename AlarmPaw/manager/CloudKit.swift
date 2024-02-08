//
//  CloudKit.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/17.
//

import CloudKit
import Foundation

class CloudKitManager {
    static let shared = CloudKitManager()
    let privateCloudDatabase = CKContainer(identifier: settings.iCloudName.rawValue).privateCloudDatabase
   
    private init() {}

    func uploadCloud(_ messages: [Message]) async -> [Message] {
        var updatedMessages: [Message] = []
        
        do {
            // Execute tasks in parallel and await their completion
            try await withThrowingTaskGroup(of: (Message, Bool).self, body: { group in
                for message in messages {
                    group.addTask { [weak self] in
                        guard let self = self else { return (message, false) }
                        let isSuccess = await self.saveMessageToCloudKit(message: message)
                        return (message, isSuccess)
                    }
                }
                
                // Process results
                for try await (message, isSuccess) in group {
                    if isSuccess {
                        updatedMessages.append(message)
                    }
                }
            })
        } catch {
            print("Error during message creation and update: \(error)")
        }
        
        return updatedMessages
    }
    
    
    // 创建CKRecord并保存到CloudKit
    func saveMessageToCloudKit(message: Message) async->Bool  {
        let record = message.createCKRecord()
        do{
            try await privateCloudDatabase.save(record)
            print("Successfully saved record to CloudKit")
            return true
        }catch{
            print(error)
        }
        return false
    }
    
    func queryCount() async -> Int{
        do{
            let result = try await self.fetchAllMessages()
            return result.count
        }catch{
            return 0
        }
    }
    
    func fetchAllMessages() async throws -> [Message] {
           let predicate = NSPredicate(value: true) // 查询所有记录
           let query = CKQuery(recordType: "Message", predicate: predicate)

           return try await withCheckedThrowingContinuation { continuation in
               var fetchedMessages = [Message]()

               // 使用 CKQueryOperation
               let operation = CKQueryOperation(query: query)
               operation.resultsLimit = CKQueryOperation.maximumResults // 或者设置为期望的限制数量

               operation.recordMatchedBlock = { recordID, result in
                   switch result {
                   case .success(let record):
                       // 转换 CKRecord 到 Message
                       let message = Message(from: record)
                       fetchedMessages.append(message)
                   case .failure(let error):
                       print("Failed to fetch record with ID \(recordID): \(error)")
                       continuation.resume(throwing: error)
                   }
               }

               operation.queryResultBlock = { result in
                   switch result {
                   case .success(_):
                       continuation.resume(returning: fetchedMessages)
                   case .failure(let error):
                       continuation.resume(throwing: error)
                   }
               }

               self.privateCloudDatabase.add(operation)
           }
       }
    
    
    
    func getCloudStatus() async -> String {
        
        do{
            let status = try await CKContainer(identifier: settings.iCloudName.rawValue).accountStatus()
            switch status {
            case .available:
                return NSLocalizedString("opened")
            case .noAccount, .restricted:
                return NSLocalizedString("notopen")
            case .couldNotDetermine:
                return NSLocalizedString("unknown")
            case .temporarilyUnavailable:
                break
            @unknown default:
                break
            }
        }catch{
            print(error)
        }
        
        return NSLocalizedString("notopen")
        
    }
    
    func deleteMessage(_ id:String) async -> Bool {
        // 指定要删除的记录的 ID
        let recordID = CKRecord.ID(recordName: id)

        // 删除
        do{
            _ = try await privateCloudDatabase.deleteRecord(withID: recordID)
            return true
        }catch{
            return false
        }
        
        
    }
    
    
    
    func deleteRecordsConcurrently(recordIDs: [CKRecord.ID]) async -> Bool {

        // 使用任务组（Task Group）来管理并发任务
        await withTaskGroup(of: Void.self) { group in
            for recordID in recordIDs {
                // 对于每个记录ID，启动一个新的并发任务
                group.addTask {
                    do {
                        _ = try await self.privateCloudDatabase.deleteRecord(withID: recordID)
                    } catch {
                        print("Failed to delete record with ID \(recordID): \(error)")
                    }
                }
            }
        }

        return true
    }
   
}

