//
//  TidyOperationsDialog.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/4/5.
//

import Foundation
import SwiftUI

struct TidyOperationDialog: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: MainViewModel
        
    @StateObject var mediaFolder: MediaFolder
    @State var applyToAll = true
    @State var saveToSettings = true

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("SelectOperationsTitle")
                    .font(.title2.bold()).frame(alignment: .topLeading)
                    .foregroundColor(colorScheme.getPrimaryColor())
                    .padding()
                Spacer()
                
                Text("SaveCommand")
                    .font(.system(size: 14).bold())
                    .foregroundColor(colorScheme.getOnSurfaceColor())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(StyledRoundedRectangle(color: colorScheme.getPrimaryColor()))
                    .onTapGesture {
                        viewModel.saveCustomTidyOperations(applyToAllFolders: applyToAll, saveToSettings: saveToSettings)
                        viewModel.toggleDialog(type: .All, show: false)
                    }
                    .hoverEffectCompat()
                
                Text("CancelCommand")
                    .font(.system(size: 14).bold())
                    .padding(4)
                    .foregroundColor(colorScheme.getPrimaryColor())
                    .onTapGesture {
                        viewModel.toggleDialog(type: .All, show: false)
                    }
                    .hoverEffectCompat()
                
                Spacer().frame(width: 12)
            }
                        
            HStack {
                Spacer().frame(width: 8, height: nil, alignment: .center)
                SimpleCheckBox(isSelected: $applyToAll)
                Text("ApplyToAllOption").font(.body).padding(.horizontal, 8).padding(.vertical, 4)
            }.frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(8)
                .onTapGesture {
                    applyToAll.toggle()
                }
            
            HStack {
                Spacer().frame(width: 8, height: nil, alignment: .center)
                SimpleCheckBox(isSelected: $saveToSettings)
                Text("SaveToSettingsOption").font(.body).padding(.horizontal, 8).padding(.vertical, 4)
            }.frame(maxWidth: .infinity, alignment: .topLeading)
                .onTapGesture {
                    saveToSettings.toggle()
                }
                .padding(8)
            
            Text("SelectOperationsSubTitle").font(.title3).foregroundColor(colorScheme.getPrimaryColor()).frame(maxWidth: .infinity, alignment: .leading).padding()
                                    
            ScrollView {
                LazyVStack {
                    ForEach($viewModel.mediaTidyOptions) { $option in
                        HStack {
                            Spacer().frame(width: 8, height: nil, alignment: .center)
                            SimpleCheckBox(isSelected: $option.isSelected)
                            Text(option.type.getLocalizedName()).font(.body).padding(.horizontal, 8).padding(.vertical, 4)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(4)
                            .background(StyledRoundedRectangle(color: colorScheme.getSurfaceColor().opacity(0.6)))
                            .onTapGesture {
                                $option.isSelected.wrappedValue.toggle()
                                if (viewModel.mediaTidyOptions.countOf(check: { o in
                                    o.isSelected
                                }) == 0) {
                                    $option.isSelected.wrappedValue = true
                                    viewModel.showToast(text: LocalizedStringKey("ToastSelectAtLeastOne"))
                                }
                            }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }.padding(EdgeInsets(top: 0, leading: 8, bottom: 4, trailing: 8))
        }.contentShape(Rectangle())
            .padding(8)
            .frame(minWidth: 400, maxWidth: 600, maxHeight: 500, alignment: .topLeading)
            .background(StyledRoundedRectangle(color: colorScheme.getBackgroundColor()))
            .transition(.slide)
    }
}

struct SimpleCheckBox: View {
    @Environment(\.colorScheme) var colorScheme
    
    var isSelected: Binding<Bool>
    
    var body: some View {
        Image(systemName: isSelected.wrappedValue ? "checkmark.circle.fill" : "circle").renderingMode(.template).foregroundColor(colorScheme.getPrimaryColor())
    }
}
