//
//  ColorScheme.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/13.
//

import Foundation
import SwiftUI

extension ColorScheme {
    func getBackgroundColor() -> Color {
        if (self == .light) {
            return Color(hex: 0xfffbf8)
        } else {
            return Color(hex: 0x161515)
        }
    }
    
    func getSurfaceColor() -> Color {
        if (self == .light) {
            return Color(hex: 0xf9f1ec)
        } else {
            return Color(hex: 0x50443c)
        }
    }
    
    func getOnSurfaceColor() -> Color {
        if (self == .light) {
            return Color(hex: 0xf2dfd2)
        } else {
            return Color(hex: 0x413831)
        }
    }
    
    func getPrimaryColor() -> Color {
        if (self == .light) {
            return Color(hex: 0x894f16)
        } else {
            return Color(hex: 0xf3bb87)
        }
    }
    
    func getSecondaryColor() -> Color {
        if (self == .light) {
            return Color(hex: 0x5f6139)
        } else {
            return Color(hex: 0xc8ca99)
        }
    }
    
    func getOnSecondaryColor() -> Color {
        if (self == .light) {
            return Color(hex: 0xfeffff)
        } else {
            return Color(hex: 0x313310)
        }
    }
    
    func getBodyTextColor() -> Color {
        if (self == .light) {
            return Color.black
        } else {
            return Color.white
        }
    }
    
    func getDividerColor() -> Color {
        if (self == .light) {
            return Color(hex: 0xf3dbe4)
        } else {
            return Color(hex: 0xf3dbe4) // todo
        }
    }
    
    func getPrimaryComplementaryColor() -> Color {
        if (self == .light) {
            return Color(hex: 0xf6f6f6)
        } else {
            return Color(hex: 0x373737) // todo
        }
    }
}
