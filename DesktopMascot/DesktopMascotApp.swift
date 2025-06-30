//
//  DesktopMascotApp.swift
//  DesktopMascot
//
//  Created by 東山友輔 on 2025/07/01.
//

import SwiftUI

@main
struct DesktopMascotApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
