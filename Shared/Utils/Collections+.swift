//
//  Collections+.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/4/5.
//

import Foundation
import SwiftUI

extension Array {
    func countOf(check: (Element) -> Bool) -> Int {
        var count = 0
        forEach { e in
            if (check(e)) {
                count = count + 1
            }
        }
        return count
    }
    
    func forEachIndexed(block: (Element, Int) -> Void) {
        var index = 0
        forEach { e in
            block(e, index)
            index = index + 1
        }
    }
}
