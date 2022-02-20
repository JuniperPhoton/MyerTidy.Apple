//
//  MainViewModel.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/12.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum SortState {
    case Pending
    case Delete
    case Group
    case Complete
}

class MainViewModel: ObservableObject {
    @Published var mediaFolders: [MediaFolder] = []
    
    @Published var state: SortState = SortState.Pending
    @Published var stateText: String? = nil
    @Published var loading = false
    
    @Published var toastText: LocalizedStringKey? = nil
    
    @Published var openFilePicker: Bool = false

    private var toastDismissWorkItem: DispatchWorkItem? = nil
    
    var hasSelctedFolder: Bool {
        get {
            return !mediaFolders.isEmpty
        }
    }

    func clear() {
        mediaFolders.removeAll()
        clearToast()
    }
    
    func showToast(text: LocalizedStringKey?, duration: Double = 4.0) {
        toastDismissWorkItem?.cancel()

        withAnimation {
            toastText = text
        }
        
        if (text == nil) {
            return
        }
        
        toastDismissWorkItem = DispatchWorkItem {
            withAnimation {
                self.toastText = nil
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration, execute: toastDismissWorkItem!)
    }
    
    func clearToast() {
        showToast(text: nil)
    }
    
    func addMediaFolders(urls: [URL]) {
        urls.forEach { url in
            addMediaFolder(forUrl: url)
        }
    }
    
    func addMediaFolder(forUrl: URL) {
        let folder = MediaFolder(url: forUrl, displayName:  forUrl.lastPathComponent)
        addMediaFolder(folder: folder)
    }
    
    func addMediaFolder(folder: MediaFolder) {
        self.removeMediaFolder(folder: folder)
        self.mediaFolders.append(folder)
        parseMediaInfos(mediaFolder: folder)
    }
    
    func removeMediaFolder(folder: MediaFolder) {
        self.mediaFolders.removeAll { f in
            f.selectedFolderURL == folder.selectedFolderURL
        }
    }
    
    func performDrop(providers: [NSItemProvider]) -> Bool {
        providers.forEach { provider in
            let identifier = provider.registeredTypeIdentifiers.first
            if (identifier == "public.url" || identifier == "public.file-url") {
                provider.loadFileRepresentation(forTypeIdentifier: identifier!) { [weak self] url, error in
                    guard let self = self else {
                        return
                    }
                    if url != nil {
                        DispatchQueue.main.async {
                            self.addMediaFolder(forUrl: url!)
                        }
                    }
                }
            }
        }
        return true
    }
    
    func performSort() {
        withAnimation {
            loading = true
        }
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.mediaFolders.forEach { folder in
                self.performSort(url: folder.selectedFolderURL, mediaInfos: folder.mediaInfos)
            }
            DispatchQueue.main.async {
                withAnimation {
                    self.loading = false
                }
                self.showToast(text: LocalizedStringKey("Success"))
            }
        }
    }
    
    private func parseMediaInfos(mediaFolder: MediaFolder) {
        withAnimation {
            loading = true
        }
        DispatchQueue.global().async {
            let mediaInfos = self.parseDirectoryInfos(rootURL: mediaFolder.selectedFolderURL)
            DispatchQueue.main.async {
                mediaFolder.mediaInfos = mediaInfos
                withAnimation {
                    self.loading = false
                }
            }
        }
    }
    
    private func performSort(url: URL, mediaInfos: [MediaInfo]) {
        // Start accessing a security-scoped resource.
            guard url.startAccessingSecurityScopedResource() else {
                print("dwccc startAccessingSecurityScopedResource failed")
                return
            }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        mediaInfos.filter({ info in
            info.isSelected
        }).forEach { info in
            if (info.action == .Group) {
                let targetFolder = url.appendingPathComponent(info.targetFolderName, isDirectory: true)
                let exists = FileManager.default.fileExists(atPath: targetFolder.absoluteString)
                if (!exists) {
                    do {
                        try FileManager.default.createDirectory(at: targetFolder, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("dwccc create item error \(error)")
                    }
                } else {
                    print("dwccc video folder \(String(describing: targetFolder.absoluteString.removingPercentEncoding)) exists \(exists)")
                }
                
                info.urls.forEach { fileURL in
                    let targetURL = targetFolder.appendingPathComponent(fileURL.lastPathComponent)

                    do {
                        try FileManager.default.moveItem(at: fileURL, to: targetURL)
                    } catch {
                        print("dwccc move item error \(error)")
                    }
                }
            } else if (info.action == .Delete) {
                info.urls.forEach { fileURL in
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {
                        print("dwccc remove item error \(error)")
                    }
                }
            }
        }
    }
    
    private func parseDirectoryInfos(rootURL: URL) -> [MediaInfo] {
        var result: [MediaInfo] = []
        
        guard rootURL.startAccessingSecurityScopedResource() else {
            print("dwccc startAccessingSecurityScopedResource failed")
            return result
        }
        
        defer { rootURL.stopAccessingSecurityScopedResource() }
        
        var error: NSError? = nil
        NSFileCoordinator().coordinate(readingItemAt: rootURL, error: &error) { (url) in
            guard let dirEnumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [], options: .skipsSubdirectoryDescendants) else {
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
                file.pathExtension
            }.forEach { (ext, urls) in
                if (ext.isEmpty) {
                    return
                }
                result.append(MediaInfo(mediaExtension: ext, action: .Group, urls: urls))
            }
        }
        
        return result.sorted { info0, info1 in
            return info0.urls.count > info1.urls.count
        }
    }
}
