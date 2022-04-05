//
//  CardView.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/3/19.
//

import Foundation
import SwiftUI

struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: MainViewModel
    
    @ObservedObject var folder: MediaFolder
    @State var byKind = true
    @State var byDate = false
    
    var onClickRemove: () -> Void
    var onClickOpenFolder: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(folder.displayName)
                    .font(.title2.bold())
                    .foregroundColor(colorScheme.getPrimaryColor())
                Image(systemName: "trash")
                    .padding(4)
                    .onTapGesture {
                        onClickRemove()
                    }
                if (viewModel.supportOpenFolder) {
                    Image(systemName: "folder")
                        .padding(4)
                        .onTapGesture {
                            onClickOpenFolder()
                        }
                }
                Spacer().frame(width: 12)
                if (folder.loading) {
                    ProgressView().controlSize(.small).transition(.opacity)
                }
            }
            
            Text("PathTitle")
                .font(.body.bold())
                .foregroundColor(colorScheme.getPrimaryColor())
            
            Text(folder.selectedFolderURL.absoluteString.removingPercentEncoding ?? "")
            
            Text("OperationTitle")
                .font(.body.bold())
                .foregroundColor(colorScheme.getPrimaryColor())
            
            ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach($folder.tidyOptions) { $option in
                            if (!($option.type.wrappedValue is EmptyTidyType)) {
                                ZStack {
                                    StyledToggle(label: option.type.getLocalizedName(), isOn: $option.isSelected).disabled(true)
                                }.disabled(folder.loading).opacity(folder.loading ? 0.3 : 1.0).contentShape(Rectangle()).onTapGesture {
                                    folder.selectType(newOption: option)
                                }
                            } else {
                                Button {
                                    viewModel.showCustomTidyOperation(folder: folder)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle").renderingMode(.template)
                                            .foregroundColor(colorScheme.getOnSurfaceColor())
                                        Text(option.type.getLocalizedName())
                                            .foregroundColor(colorScheme.getOnSurfaceColor())
                                            .padding(4)
                                    }.padding(.horizontal, 8).background(StyledRoundedRectangle(color: colorScheme.getPrimaryColor()))
                                }.buttonStyle(.plain)
                            }
                        }
                        Spacer().frame(width: 30)
                    }
                }
                HStack {
                    LinearGradient(colors: [colorScheme.getSurfaceColor().opacity(0), colorScheme.getSurfaceColor()], startPoint: .leading, endPoint: .trailing)
                        .frame(width: 50)
                }.frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Text("FileInfo")
                .font(.body.bold())
                .foregroundColor(colorScheme.getPrimaryColor())
            
            if (folder.mediaInfos.isEmpty) {
                Text("NoMediaFound")
            } else {
                LazyVStack {
                    ForEach($folder.mediaInfos) { $info in
                        MediaInfoView(info: $info)
                        if (folder.mediaInfos.last?.id != info.id) {
                            Divider().foregroundColor(colorScheme.getDividerColor()).opacity(0.3)
                        }
                    }
                }
                
            }
        }.padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(StyledRoundedRectangle(color: colorScheme.getSurfaceColor()).addShadow())
    }
}
