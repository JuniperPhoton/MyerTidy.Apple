//
//  MainNavigator.swift
//  MyerTidy (macOS)
//
//  Created by juniperphoton on 2022/2/20.
//

import Foundation
import SwiftUI

enum Page {
    case Main
    case About
    case Settings
}

class MainNavigator: ObservableObject {
    @Published var page = Page.Main

    func navigateTo(page: Page) {
        withAnimation {
            self.page = page
        }
    }
}
