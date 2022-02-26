//
//  View+Drop.swift
//  MyerTidy (macOS)
//
//  Created by juniperphoton on 2022/2/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func performDrop(isTargeted: Binding<Bool>, onSelectedProviders: @escaping ([NSItemProvider], CGPoint) -> Bool) -> some View {
        self.onDrop(of: [UTType.fileURL, UTType.folder], isTargeted: isTargeted, perform: onSelectedProviders)
    }
}
