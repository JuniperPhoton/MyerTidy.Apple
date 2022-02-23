//
//  AboutView.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/13.
//

import Foundation
import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: AboutViewModel = AboutViewModel()
    
    var onClickBack: ()->Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                HStack {
                    Image("AboutIcon", bundle: .main)
                        .resizable()
                        .frame(width: 70, height: 70)
                    Text("Myer")
                        .font(.system(size: 40).weight(.thin))
                        .foregroundColor(colorScheme.getPrimaryColor())
                    Text("Tidy")
                        .offset(x: -6, y: 0)
                        .font(.system(size: 40).bold())
                        .foregroundColor(colorScheme.getPrimaryColor())
                }
                
                Text("For iOS, iPadOS & macOS")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                    .foregroundColor(colorScheme.getPrimaryColor())
                
                Text("AboutText")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                    .foregroundColor(colorScheme.getPrimaryColor())
                
                Text("Versions \(viewModel.version)")
                    .font(.title.bold())
                    .foregroundColor(colorScheme.getOnSecondaryColor())
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(RoundedRectangle(cornerRadius: 30).fill(colorScheme.getSecondaryColor()))
                
                Text("Feedback")
                    .font(.title.bold())
                    .underline()
                    .foregroundColor(colorScheme.getPrimaryColor())
                    .onTapGesture {
                        viewModel.sendFeedback()
                    }
                Text("GitHub")
                    .font(.title.bold())
                    .underline()
                    .foregroundColor(colorScheme.getPrimaryColor())
                    .onTapGesture {
                        viewModel.navigateToGitHub()
                    }
            }
            VStack {
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .foregroundColor(colorScheme.getPrimaryColor())
                    .padding(24)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onClickBack)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }.padding(16).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center).background(colorScheme.getBackgroundColor())
    }
}
