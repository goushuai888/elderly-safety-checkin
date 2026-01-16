//
//  SiLeMoApp.swift
//  死了么
//
//  Created by shuai on 2026/1/16.
//

import SwiftUI

@main
struct SiLeMoApp: App {
    @StateObject private var dataManager = DataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
