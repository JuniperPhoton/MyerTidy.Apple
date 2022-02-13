//
//  UIExtensions.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/12.
//

import Foundation
import SwiftUI

struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

struct MatchParent: ViewModifier {
    var matchWidth: Bool
    var matchHeight: Bool
    
    func body(content: Content) -> some View {
        content.frame(maxWidth: matchWidth ? .infinity : nil, maxHeight: matchHeight ? .infinity : nil)
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

extension View {
    func assist() -> some View {
        self.background(Color.blue)
    }
}

extension View {
    func addShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 3, x: 3, y: 3)
    }
}
