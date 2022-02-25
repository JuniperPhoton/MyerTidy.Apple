//
//  MediaInfo.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/12.
//

import Foundation
import SwiftUI

class MediaInfo: Identifiable, ObservableObject {
    var groupKey: String = ""
    var urls: [URL] = []
    
    var isSelected: Bool = true
    
    var targetFolderName: String {
        get {
            return groupKey.uppercased()
        }
    }
    
    @Published var action: MediaAction = .Group
    
    init(groupKey: String, action: MediaAction, urls: [URL]) {
        self.groupKey = groupKey
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
