//
//  msgManager.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/2/17.
//

import UIKit
import Foundation
import RealmSwift
import Photos
import SwiftUI

func filterMessage(_ messages:Results<Message>,searchText:String)-> Results<Message>{
    if searchText == ""{
        return messages
    }
    
    let resultFilter = messages.filter(NSPredicate(format: "title CONTAINS[c] %@ OR body CONTAINS[c] %@", searchText, searchText))
    
    return resultFilter.sorted(by: [ SortDescriptor(keyPath: "isRead", ascending: true),SortDescriptor(keyPath: "createDate", ascending: false)])
}




class ImageSaver: NSObject {
   
    // 定义完成回调类型
    var completionHandler: ((Bool, Error?) -> Void)?

    // 调用此方法来保存图片
    func saveImage(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        self.completionHandler = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    // 保存完成时被调用的方法
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completionHandler?(error == nil, error)
    }
    
    func requestAuthorizationAndSaveImage(url:String,_ complate: @escaping (saveType)->Void) {
        guard let image = self.downloadImage(url: url) else{
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.saveImage(image: image) { success, error in
                    if !success{
                        print("error: \(String(describing: error?.localizedDescription))")
                    }
                    complate( success ? .success : .failSave)
                }
            } else {
                // 处理未获得权限的情况
                complate(.failAuth)
            }
        }
    }
    
    func requestAuthorizationAndSaveImage(image:UIImage,_ complate: @escaping (saveType)->Void) {

        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.saveImage(image: image) { success, error in
                    if !success{
                        print("error: \(String(describing: error?.localizedDescription))")
                    }
                    complate( success ? .success : .failSave)
                }
            } else {
                // 处理未获得权限的情况
                complate(.failAuth)
            }
        }
    }
    
    
    
    private func downloadImage(url: String)-> UIImage?{
        guard let imageUrl = URL(string: url) else {
            return nil
        }
        let urlRequest: URLRequest = URLRequest(url: imageUrl)
        let session: URLSession = .imageSession
        if let data = session.configuration.urlCache?.cachedResponse(for: urlRequest)?.data,
           let uiImage = UIImage(data: data) {
            return uiImage
            
        }
        return nil
    }
    
}
