//
//  NSItemProvider+GetUrl.swift
//  MyerTidy (iOS)
//
//  Created by juniperphoton on 2022/2/26.
//

import Foundation

extension NSItemProvider {
    func loadUrl(onComplete: (URL?) -> Void) {
        onComplete(nil)
    }
}
