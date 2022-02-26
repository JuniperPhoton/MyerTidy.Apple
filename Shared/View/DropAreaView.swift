//
//  DropAreaView.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/13.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct DropAreaView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var isTargeted: Bool = false
    
    var onSelectedProviders: ([NSItemProvider], CGPoint) -> Bool
    
    var body: some View {
        DropHintView(isTargeted: $isTargeted).performDrop(isTargeted: $isTargeted, onSelectedProviders: onSelectedProviders)
    }
}

struct DropHintView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isTargeted: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus").renderingMode(.template)
                .foregroundColor(colorScheme.getPrimaryColor().opacity(0.5)).font(.system(size: 120, weight: .bold))
            Text(isTargeted ? "DropHereHint" : (supportDrop() ? "DragAreaHint" : "NonDragAreaHint")).transition(.opacity)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background($isTargeted.wrappedValue ? colorScheme.getSurfaceColor().opacity(0.5): Color.clear)
    }
}
