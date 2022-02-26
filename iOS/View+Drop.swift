//
//  View+Drop.swift
//  MyerTidy (iOS)
//
//  Created by juniperphoton on 2022/2/26.
//

import Foundation
import SwiftUI

extension View {
    func supportDrop() -> Bool {
        return false
    }
    
    func performDrop(isTargeted: Binding<Bool>, onSelectedProviders: @escaping ([NSItemProvider], CGPoint) -> Bool) -> some View {
        return self
    }
}
