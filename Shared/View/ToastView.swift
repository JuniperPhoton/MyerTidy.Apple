//
//  ToastView.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/3/19.
//

import Foundation
import SwiftUI

struct ToastView: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            if (viewModel.toastText != nil) {
                Text(viewModel.toastText!).foregroundColor(.black)
                    .padding(8)
                    .background(StyledRoundedRectangle(color: .white))
                    .addShadow()
                    .transition(.opacity)
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)).frame(height: 60, alignment: .trailing).clipped()
    }
}
