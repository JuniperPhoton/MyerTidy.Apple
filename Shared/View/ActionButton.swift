//
//  ActionButton.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/13.
//

import Foundation
import SwiftUI

struct ActionButton: View {
    @State var isHovered = false
    @State var isTapped = false
    
    var title: String
    var icon: String? = nil
    var backgroundColor: Color = Color(hex: 0xf8dae4)
    var matchParent: Bool = false
    var onClick: ()-> Void
    
    var body: some View {
        HStack {
            if (icon != nil) {
                Image(systemName: icon!)
            }
            Text(title)
                .font(.body.bold())
                .foregroundColor(.black)
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
