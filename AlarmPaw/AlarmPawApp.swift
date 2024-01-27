//
//  AlarmPawApp.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/13.
//

import SwiftUI
import SwiftData

@main
struct AlarmPawApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var paw = pawManager.shared
    private let timerz = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(paw)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    if let badge = RealmManager.shared.getUnreadCount(){
                        paw.changeBadge(badge: badge)
                    }
                }.task {
                    paw.monitorNetwork()
                    paw.monitorNotification()
                }
        }
    }
}
