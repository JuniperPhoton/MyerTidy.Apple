//
//  URILauncher.swift
//  MyerTidy (iOS)
//
//  Created by juniperphoton on 2022/2/23.
//

import Foundation
import UIKit

extension URILauncher {
    static func supportOpenFolder() -> Bool {
        return false
    }
    
    static func openURI(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
