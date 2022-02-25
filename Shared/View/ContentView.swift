//
//  ContentView.swift
//  Shared
//
//  Created by juniperphoton on 2022/2/12.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var viewModel: MainViewModel = MainViewModel()
    @StateObject var mainNavigator = MainNavigator()
    
    var body: some View {
        switch mainNavigator.page {
        case .Main:
            MainPage(viewModel: viewModel, mainNavigator: mainNavigator)
        case .About:
            AboutView{
                mainNavigator.navigateTo(page: .Main)
            }.mainPageFrame()
                .transition(AnyTransition.asymmetric(insertion: .offset(x: 0, y: 200), removal: .offset(x: 0, y: 200)).combined(with: .opacity).animation(.easeIn(duration: 0.2)))
        case .Settings:
            AboutView{
                mainNavigator.navigateTo(page: .Main)
            }.mainPageFrame()
        }
    }

}

struct MainPage: View {
    @StateObject var viewModel: MainViewModel
    @StateObject var mainNavigator: MainNavigator
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("AppName").font(.largeTitle.bold()).frame(alignment: .topLeading)
                    .foregroundColor(colorScheme.getPrimaryColor())
                Spacer().frame(width: 20)

                if (viewModel.loading) {
                    ProgressView().controlSize(.small).transition(.opacity)
                }
                
                Spacer()
                
                ToastView().environmentObject(viewModel)
                
                Image(systemName: "gear").renderingMode(.template).resizable().frame(width: 20, height: 20, alignment: .center).foregroundColor(colorScheme.getPrimaryColor())
                    .onTapGesture {
                        viewModel.showComingSoon()
                    }
                
                Spacer().frame(width: 20)
                Image(systemName: "info.circle").renderingMode(.template).resizable().frame(width: 20, height: 20, alignment: .center).foregroundColor(colorScheme.getPrimaryColor())
                    .onTapGesture {
                        mainNavigator.navigateTo(page: .About)
                    }
                Spacer().frame(width: 16)
            }.frame(height: 60)
            
            if (viewModel.hasSelctedFolder) {
                contentView().transition(AnyTransition.asymmetric(insertion: .offset(x: -100, y: 0), removal: .offset(x: 100, y: 0)).combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
            } else {
                emptyView().transition(AnyTransition.asymmetric(insertion: .offset(x: 100, y: 0), removal: .offset(x: -100, y: 0)).combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
            }
        }.padding(24)
            .mainPageFrame()
            .background(colorScheme.getBackgroundColor())
            .transition(AnyTransition.asymmetric(insertion: .offset(x: 0, y: 200), removal: .offset(x: 0, y: 200)).combined(with: .opacity).animation(.easeIn(duration: 0.2)))
            .importFolder(isPresented: $viewModel.openFilePicker, onSucess: { urls in
                withAnimation {
                    viewModel.addMediaFolders(urls: urls)
                }
            })
    }
    
    private func contentView() -> some View {
        return VStack {
            ScrollView {
                ForEach($viewModel.mediaFolders) { $folder in
                    CardView(folder: folder, onClickRemove: {
                        withAnimation {
                            viewModel.removeMediaFolder(folder: folder)
                        }
                    }, onClickOpenFolder: {
                        viewModel.openFolder(folder: folder)
                    }).padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 12)).environmentObject(viewModel)
                }
            }
            
            Spacer()
                                    
            HStack {
                ActionButton(title: "TidyUpButton", icon: "wrench.and.screwdriver", foregroundColor: colorScheme.getOnSecondaryColor(), backgroundColor: colorScheme.getSecondaryColor(), matchParent: true) {
                    viewModel.performSort()
                }.addShadow()
                
                Spacer()
                
                ActionButton(title: "AddMoreButton", icon: "folder.badge.plus", foregroundColor: colorScheme.getOnSecondaryColor(), backgroundColor: colorScheme.getSecondaryColor().opacity(0.8)) {
                    viewModel.openFilePicker = true
                }.addShadow()
                
                ActionButton(title: nil, icon: "xmark", foregroundColor: colorScheme.getBodyTextColor(), backgroundColor: colorScheme.getPrimaryComplementaryColor()) {
                    withAnimation {
                        viewModel.clear()
                    }
                }.addShadow()
            }.frame(maxWidth: .infinity).opacity(viewModel.loading ? 0.5 : 1.0).disabled(viewModel.loading)
            
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func emptyView() -> some View {
        ZStack {
            DropAreaView { provider, location in
                return viewModel.performDrop(providers: provider)
            }
            
            VStack {
                ActionButton(title: LocalizedStringKey("SelectFolderButton"), icon: "folder.badge.plus", foregroundColor: colorScheme.getOnSecondaryColor(), backgroundColor: colorScheme.getSecondaryColor()) {
                    viewModel.openFilePicker = true
                }.addShadow()
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ToastView: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            if (viewModel.toastText != nil) {
                Text(viewModel.toastText!).foregroundColor(.black)
                    .padding(8)
                    .background(StyledRoundedRectangle(color: .white))
                    .addShadow()
                    .transition(.move(edge: .trailing))
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)).frame(height: 60, alignment: .trailing).clipped()
    }
}

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
                                viewModel.showComingSoon()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle").renderingMode(.template)
                                        .foregroundColor(.white)
                                    Text(option.type.getLocalizedName())
                                        .foregroundColor(.white)
                                        .padding(4)
                                }.padding(.horizontal, 8).background(StyledRoundedRectangle(color: colorScheme.getPrimaryColor()))
                            }.buttonStyle(.plain)
                        }
                    }
                }
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

struct MediaInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var info: MediaInfo
    
    @State var expand: Bool = false
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                if (expand) {
                    ForEach(info.urls) { url in
                        HStack(alignment: .lastTextBaseline) {
                            imageFromMediaType(mediaInfo: info)
                            Text(url.lastPathComponent).lineLimit(1)
                                .truncationMode(.middle)
                                .padding([.top])
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.frame(alignment: .center)
                    }
                }
            } header: {
                HStack(alignment: .center) {
                    StyledToggle(label: LocalizedStringKey(stringLiteral: info.groupKey.uppercased()), isOn: $info.isSelected)
                    Button(action: {
                        withAnimation {
                            expand.toggle()
                        }
                    }) {
                        HStack {
                            Text("\(String(info.urls.count))ItemsText")
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(expand ? 180 : 0))
                        }.contentShape(Rectangle())
                    }.buttonStyle(.plain)
                    
                    Spacer()
                    HStack {
                        ActionMenuView(mediaInfo: info)
                        GroupTextField(mediaInfo: info)
                    }.padding(6).background(StyledRoundedRectangle(color: colorScheme.getOnSurfaceColor().opacity(0.5))).clipped()
                    
                }.frame(width: nil, height: 50, alignment: .leading).background(colorScheme.getSurfaceColor())
            }
        }
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

struct GroupTextField: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var mediaInfo: MediaInfo
    
    var body: some View {
        if (mediaInfo.action == .Group) {
            TextField("Group", text: $mediaInfo.groupName)
                .foregroundColor(colorScheme.getBodyTextColor())
                .textFieldStyle(.plain)
                .frame(width: 80)
                .transition(.move(edge: .trailing))
        } else {
            EmptyView()
        }
    }
}

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
                        .symbolRenderingMode(.monochrome)
                        .foregroundColor(colorScheme.getPrimaryColor())
                }
            }
        } label: {
            HStack {
                Text(mediaInfo.action.toString()).foregroundColor(colorScheme.getPrimaryColor())
                    .frame(maxWidth: .infinity)
                    .font(.body.bold())
                Image(systemName: mediaInfo.action == .Group ? "folder" : "trash")
                    .renderingMode(.template)
                    .tint(colorScheme.getPrimaryColor())
                    .foregroundColor(colorScheme.getPrimaryColor())
            }
        }.frame(width: 80)
            .menuStyle(.borderlessButton)
    }
}

struct StyledToggle: View {
    @Environment(\.colorScheme) var colorScheme
    
    var label: LocalizedStringKey
    var isOn: Binding<Bool>
    
    var body: some View {
        Toggle(label, isOn: isOn)
            .toggleStyle(CustomToggleStyle()).background(StyledRoundedRectangle(color: colorScheme.getOnSurfaceColor()))
    }
}

struct StyledRoundedRectangle: View {
    @Environment(\.colorScheme) var colorScheme
    
    var color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous).fill(color)
    }
}

struct CustomToggleStyle: ToggleStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle").renderingMode(.template).foregroundColor(colorScheme.getPrimaryColor())
            configuration.label
        }.padding(4).contentShape(Rectangle()).onTapGesture {
            configuration.isOn.toggle()
        }
    }
}

extension View {
    func mainPageFrame() -> some View {
        self.frame(minWidth: 400, minHeight: 600, alignment: .topLeading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
