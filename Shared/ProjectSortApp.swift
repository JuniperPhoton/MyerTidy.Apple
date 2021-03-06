//
//  ProjectSortApp.swift
//  Shared
//
//  Created by juniperphoton on 2022/2/12.
//

import SwiftUI

@main
struct ProjectSortApp: App {
    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
        }.windowStyle(.hiddenTitleBar)
        #else
        WindowGroup {
            ContentView()
        }
        #endif
    }
}
