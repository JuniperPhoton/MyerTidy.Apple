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
    @Published var supportOpenFolder: Bool = URILauncher.supportOpenFolder()
    
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
    
    func showToast(text: LocalizedStringKey?, durationSec: Double = 4.0) {
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
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + durationSec, execute: toastDismissWorkItem!)
    }
    
    func clearToast() {
        showToast(text: nil)
    }
    
    func showComingSoon() {
        showToast(text: "ToastCommingSoon", durationSec: 2)
    }
    
    func addMediaFolders(urls: [URL]) {
        urls.forEach { url in
            addMediaFolder(forUrl: url)
        }
    }
    
    func addMediaFolder(forUrl: URL) {
        let folder = MediaFolder(url: forUrl, displayName: forUrl.lastPathComponent)
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
    
    func openUrl(url: URL) {
        URILauncher.openURI(url: url)
    }
    
    func openFolder(folder: MediaFolder) {
        URILauncher.openURI(url: folder.selectedFolderURL)
    }
    
    func performDrop(providers: [NSItemProvider]) -> Bool {
        providers.forEach { provider in
            let identifier = provider.registeredTypeIdentifiers.first
            if (identifier == "public.url" || identifier == "public.file-url" || identifier == "public.folder") {
                provider.loadUrl { [weak self] url in
                    Logger.logI(message: "performDrop load url: \(String(describing: url))")
                    guard let self = self else {
                        return
                    }
                    guard let url = url else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.addMediaFolder(forUrl: url)
                    }
                }
            } else {
                Logger.logW(message: "identifier is unknown: \(String(describing: identifier))")
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
                self.performSort(folder: folder)
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
        mediaFolder.updateMediaInfoByTidyType {
            withAnimation {
                self.loading = false
            }
        }
    }
    
    private func performSort(folder: MediaFolder) {
        let url = folder.selectedFolderURL
        // Start accessing a security-scoped resource.
        let granted = url.startAccessingSecurityScopedResource()
        Logger.logW(message: "performSort startAccessingSecurityScopedResource \(granted)")
        
        defer {
            if (granted) {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        folder.mediaInfos.filter({ info in
            info.isSelected
        }).forEach { info in
            info.action.performAction(url: url, info: info)
        }
        
        folder.updateMediaInfoByTidyType()
    }
}
