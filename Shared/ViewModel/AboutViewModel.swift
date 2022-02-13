//
//  AboutViewModel.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/13.
//

import Foundation
import SwiftUI

class AboutViewModel: ObservableObject {
    @Published var version: String
    
    init() {
        version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    func sendFeedback() {
        let url = URL(string: "mailto:dengweichao@hotmail.com?subject=MyerTidy(\(version))Feedback")!
#if os(macOS)
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
#else
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
#endif
    }
    
    func navigateToGitHub() {
        let url = URL(string: "https://github.com/JuniperPhoton/ProjectSort")!
#if os(macOS)
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
#else
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
#endif
    }
}
