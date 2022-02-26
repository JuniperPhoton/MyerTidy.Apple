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
        URILauncher.openURI(url: url)
    }
    
    func navigateToTwitter() {
        let url = URL(string: "https://twitter.com/JuniperPhoton")!
        URILauncher.openURI(url: url)
    }
}
