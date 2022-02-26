//
//  NSItemProvider+GetUrl.swift
//  MyerTidy (macOS)
//
//  Created by juniperphoton on 2022/2/26.
//

import Foundation
import AppKit

extension NSItemProvider {
    func loadUrl(onComplete: @escaping (URL?) -> Void) {
        _ = self.loadObject(ofClass: NSPasteboard.PasteboardType.self) { pasteboardItem, _ in
            guard let rawValue = pasteboardItem?.rawValue else {
                onComplete(nil)
                return
            }

            onComplete(URL(string: rawValue)!)
        }
    }
}
