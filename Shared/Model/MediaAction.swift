//
//  MediaAction.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/2/23.
//

import Foundation
import SwiftUI

enum MediaAction: String, CaseIterable, Identifiable, RawRepresentable {
    case Group = "ActionGroup"
    case Trash = "ActionTrash"
    case Delete = "ActionDelete"

    var id: String { self.rawValue }
    
    func toString() -> LocalizedStringKey {
        return LocalizedStringKey(self.rawValue)
    }
    
    func performAction(url: URL, info: MediaInfo) {
        switch info.action {
        case .Group:
            let targetFolder = url.appendingPathComponent(info.groupName, isDirectory: true)
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
            break
        case .Trash:
            info.urls.forEach { fileURL in
                do {
                    try FileManager.default.trashItem(at: fileURL, resultingItemURL: nil)
                } catch {
                    print("dwccc trash item error \(error)")
                }
            }
            break
        case .Delete:
            info.urls.forEach { fileURL in
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    print("dwccc remove item error \(error)")
                }
            }
            break
        }
    }
}
