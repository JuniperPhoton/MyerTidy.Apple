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
    
    @Published var tidyOptions: [MediaTidyOption] = [
        MediaTidyOption(isSelected: true, type: FileExtensionTidyType()),
        MediaTidyOption(isSelected: false, type: FileCreationDayTidyType()),
        MediaTidyOption(isSelected: false, type: EmptyTidyType())
    ]
    
    @Published var loading = false
        
    init(url: URL, displayName: String) {
        self.selectedFolderURL = url
        self.displayName = displayName
    }
    
    func selectType(newOption: MediaTidyOption) {
        tidyOptions.forEach { option in
            option.isSelected = option == newOption
        }
        updateMediaInfoByTidyType()
        objectWillChange.send()
    }
    
    func updateMediaInfoByTidyType(onComplete: (()->Void)? = nil) {
        guard let option = tidyOptions.first(where: { o in
            o.isSelected
        }) else {
            return
        }
        
        withAnimation {
            loading = true
        }
        
        DispatchQueue.global().async {
            let mediaInfos = self.parseDirectoryInfos(rootURL: self.selectedFolderURL, type: option.type)
            DispatchQueue.main.async {
                withAnimation {
                    self.mediaInfos = mediaInfos
                    self.loading = false
                }
                onComplete?()
            }
        }
    }
    
    private func parseDirectoryInfos(rootURL: URL, type: URLTidyType) -> [MediaInfo] {
        var result: [MediaInfo] = []
        
        guard rootURL.startAccessingSecurityScopedResource() else {
            print("dwccc startAccessingSecurityScopedResource failed")
            return result
        }
        
        defer { rootURL.stopAccessingSecurityScopedResource() }
        
        var error: NSError? = nil
        NSFileCoordinator().coordinate(readingItemAt: rootURL, error: &error) { (url) in
            guard let dirEnumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [], options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]) else {
                Swift.debugPrint("*** dwccc Unable to access the contents of \(url.path) ***\n")
                return
            }
            
            let files = dirEnumerator.filter { item in
                let fileURL = item as! URL
                return !fileURL.hasDirectoryPath
            }.map { item in
                item as! URL
            }
            
            Dictionary(grouping: files) { file in
                return type.getGroupKey(input: file)
            }.filter({ item in
                item.key != nil && item.key?.isEmpty == false
            }).forEach { (key, urls) in
                result.append(MediaInfo(groupKey: key!, action: .Group, urls: urls))
            }
        }
        
        return result.sorted { info0, info1 in
            return info0.urls.count > info1.urls.count
        }
    }
}

class MediaTidyOption: Identifiable {
    @Published var isSelected = false
    @Published var type: URLTidyType
    
    init(isSelected: Bool, type: URLTidyType) {
        self.isSelected = isSelected
        self.type = type
    }
    
    static func == (lhs: MediaTidyOption, rhs: MediaTidyOption) -> Bool {
        return lhs.type == rhs.type
    }
}
