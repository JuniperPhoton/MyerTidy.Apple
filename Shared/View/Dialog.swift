//
//  Dialog.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/4/5.
//

import Foundation
import SwiftUI

struct Dialog<Content: View>: View {
    @EnvironmentObject var viewModel: MainViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Rectangle().fill(.black.opacity(0.4))
                .onTapGesture {
                    viewModel.toggleDialog(type: .All, show: false)
                }
            content.zIndex(100)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
