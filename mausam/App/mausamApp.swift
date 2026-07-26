//
//  mausamApp.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import SwiftUI

@main
struct mausamApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .backgroundTask(
            .appRefresh(BackgroundRefreshService.taskIdentifier)
        ) {
            print("Mausam background refresh started")
            await BackgroundRefreshService()
                 .performRefresh()
        }
    }
}
