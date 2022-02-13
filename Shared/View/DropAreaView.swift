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
    @State var isTargeted: Bool = false
    
    var onSelectedProviders: ([NSItemProvider], CGPoint) -> Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus").renderingMode(.template)
                .foregroundColor(Color(hex: 0xe6def7)).font(.system(size: 120, weight: .bold))
            Text(isTargeted ? "Drop here" : "Drop folders here or click the button to begin").transition(.opacity)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted, perform: onSelectedProviders)
    }
}
