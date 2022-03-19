//
//  MediaInfoView.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/3/19.
//

import Foundation
import SwiftUI

struct MediaInfoView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @Environment(\.colorScheme) var colorScheme
    
#if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
#endif
    
    @Binding var info: MediaInfo
    
    @State var expand: Bool = false
    
    var body: some View {
        VStack {
#if os(macOS)
            getRegularContentView()
#else
            if (sizeClass == .compact) {
                getCompactContentView()
            } else {
                getRegularContentView()
            }
#endif
            
            if (expand) {
                LazyVStack {
                    ForEach(info.urls) { url in
                        HStack(alignment: .lastTextBaseline) {
                            imageFromMediaType(mediaInfo: info)
                            Text(url.lastPathComponent).lineLimit(1)
                                .truncationMode(.middle)
                                .padding([.top])
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.frame(alignment: .center).contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.openUrl(url: url)
                            }
                    }
                }
                
            }
        }
    }
    
    private func actionMenu() -> some View {
        HStack {
            ActionMenuView(mediaInfo: info)
            GroupTextField(mediaInfo: info)
        }.padding(6).background(StyledRoundedRectangle(color: colorScheme.getOnSurfaceColor().opacity(0.5))).clipped()
    }
    
    private func toggleFilesButton() -> some View {
        Button(action: {
            withAnimation {
                expand.toggle()
            }
        }) {
            HStack {
                Text("\(String(info.urls.count))ItemsText").lineLimit(1)
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(expand ? 180 : 0))
            }.contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
    
    private func getRegularContentView() -> some View {
        HStack(alignment: .center) {
            StyledToggle(label: LocalizedStringKey(stringLiteral: info.groupKey.uppercased()), isOn: $info.isSelected)
            toggleFilesButton()
            Spacer()
            actionMenu()
        }.frame(width: nil, height: 50, alignment: .leading).background(colorScheme.getSurfaceColor())
    }
    
    private func getCompactContentView() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                StyledToggle(label: LocalizedStringKey(stringLiteral: info.groupKey.uppercased()), isOn: $info.isSelected)
                Spacer()
                actionMenu()
            }.frame(width: nil, height: 50, alignment: .leading).background(colorScheme.getSurfaceColor())
            toggleFilesButton()
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func imageFromMediaType(mediaInfo: MediaInfo) -> some View {
        if (["jpg", "jpeg", "dng"].contains(mediaInfo.groupKey.lowercased())) {
            return Image(systemName: "photo")
        } else if (["mp4", "mov"].contains(mediaInfo.groupKey.lowercased())) {
            return Image(systemName: "video")
        } else if (["txt"].contains(mediaInfo.groupKey.lowercased())){
            return Image(systemName: "doc.text")
        } else {
            return Image(systemName: "doc")
        }
    }
}
