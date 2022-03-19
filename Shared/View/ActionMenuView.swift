//
//  ActionMenuView.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/3/19.
//

import Foundation
import SwiftUI

struct ActionMenuView: View  {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var mediaInfo: MediaInfo
    
    var body: some View {
        Menu {
            ForEach(MediaAction.allCases) { action in
                Button(action: {
                    withAnimation {
                        mediaInfo.action = action
                    }
                }) {
                    Label(action.toString(), systemImage: action == .Group ? "folder" : "trash")
                        .foregroundColor(colorScheme.getPrimaryColor())
                }
            }
        } label: {
            HStack {
                Image(systemName: mediaInfo.action == .Group ? "folder" : "trash")
                    .renderingMode(.template)
                    .foregroundColor(colorScheme.getPrimaryColor())
                Text(mediaInfo.action.toString()).foregroundColor(colorScheme.getPrimaryColor())
                    .font(.body.bold())
            }
        }.frame(maxWidth: 120)
            .menuStyle(.borderlessButton)
    }
}
