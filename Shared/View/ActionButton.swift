//
//  ActionButton.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/13.
//

import Foundation
import SwiftUI

struct ActionButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var isHovered = false
    @State var isTapped = false
    
    var title: LocalizedStringKey
    var icon: String? = nil
    var foregroundColor: Color
    var backgroundColor: Color
    var matchParent: Bool = false
    var onClick: ()-> Void
    
    var body: some View {
        HStack {
            if (icon != nil) {
                Image(systemName: icon!).renderingMode(.template).foregroundColor(foregroundColor)
            }
            Text(title)
                .font(.body.bold())
                .foregroundColor(foregroundColor)
        }.padding(15)
            .modifier(matchParent ? MatchParent(matchWidth: true, matchHeight: false) : MatchParent(matchWidth: false, matchHeight: false))
            .background(background)
            .onTapGesture {
                isHovered = false
                onClick()
            }
            .modifier(PressActions(onPress: {
                withAnimation {
                    isTapped = true
                }
            }, onRelease: {
                withAnimation {
                    isTapped = false
                    isHovered = false
                }
            }))
            .onHover { hover in
                withAnimation {
                    isHovered = hover
                }
            }
            .hoverEffectCompat()
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous).fill(backgroundColor).opacity(getOpacityOnViewState())
    }
    
    private func getOpacityOnViewState() -> Double {
        if (isHovered) {
            return 0.7
        }
        
        if (isTapped) {
            return 0.6
        }
        
        return 1.0
    }
}
