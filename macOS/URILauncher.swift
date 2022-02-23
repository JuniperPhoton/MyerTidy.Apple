//
//  URLLauncher.swift
//  MyerTidy (iOS)
//
//  Created by juniperphoton on 2022/2/23.
//

import Foundation
import AppKit

extension URILauncher {
    static func supportOpenFolder() -> Bool {
        return true
    }
    
    static func openURI(url: URL) {
        NSWorkspace.shared.open(url)
    }
}
