//
//  MediaInfo.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/12.
//

import Foundation
import SwiftUI

enum MediaAction: String, CaseIterable, Identifiable, RawRepresentable {
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
    
    var id: String { self.rawValue }
}

class MediaInfo: Identifiable, ObservableObject {
    var mediaExtension: String = ""
    var urls: [URL] = []
    
    var isSelected: Bool = true
    
    var targetFolderName: String {
        get {
            return mediaExtension.uppercased()
        }
    }
    
    @Published var action: MediaAction = .Group
    
    init(mediaExtension: String, action: MediaAction, urls: [URL]) {
        self.mediaExtension = mediaExtension
        self.urls = urls
        self.action = action
    }
}

extension URL: Identifiable {
    public var id: String {
        get {
            return self.absoluteString
        }
    }
}
