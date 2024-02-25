//
//  musicView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/21.
//

import SwiftUI
import AVFoundation
import UIKit

struct musicView: View {
    @State var toastText = ""
    @StateObject var audioPlayerManager = AudioPlayerManager()
    var body: some View {
        List {
            ForEach(listFilesInDirectory(), id: \.self) { url in
                musicCellView(audio: url,audioPlayerManager: audioPlayerManager,toastText: $toastText)
            }
        }.toast(info: $toastText)
    }
}


extension musicView{
    func listFilesInDirectory() -> [ URL] {
        var urls =  Bundle.main.urls(forResourcesWithExtension: "caf", subdirectory: nil) ?? []
        urls.sort { u1, u2 -> Bool in
            u1.lastPathComponent.localizedStandardCompare(u2.lastPathComponent) == ComparisonResult.orderedAscending
        }
        
        return urls
    }
    

}





#Preview {
    musicView()
}
