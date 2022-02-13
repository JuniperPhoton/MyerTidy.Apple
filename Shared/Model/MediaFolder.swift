//
//  MediaFolder.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/13.
//

import Foundation
import SwiftUI

class MediaFolder: Identifiable, ObservableObject {
    @Published var selectedFolderURL: URL
    @Published var displayName: String
    @Published var mediaInfos: [MediaInfo] = []
    
    init(url: URL, displayName: String) {
        self.selectedFolderURL = url
        self.displayName = displayName
    }
}
