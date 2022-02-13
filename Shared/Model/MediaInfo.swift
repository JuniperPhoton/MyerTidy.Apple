//
//  MediaInfo.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/12.
//

import Foundation
import SwiftUI

enum MediaAction {
    case Delete
    case Group
    
    func toString() -> LocalizedStringKey {
        switch self {
        case .Delete:
            return LocalizedStringKey("ActionDelete")
        case .Group:
            return LocalizedStringKey("ActionGroup")
        }
    }
}

class MediaInfo: Identifiable {
    var mediaExtension: String = ""
    var urls: [URL] = []
    
    var isSelected: Bool = true
    
    var targetFolderName: String {
        get {
            return mediaExtension.uppercased()
        }
    }
    
    var action: MediaAction = .Group
    
    init(mediaExtension: String, action: MediaAction, urls: [URL]) {
        self.mediaExtension = mediaExtension
        self.urls = urls
        self.action = action
    }
}
