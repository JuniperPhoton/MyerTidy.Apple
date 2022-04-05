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
                .transition(.move(edge: .bottom))
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
    
    @State var isDropTarget = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                HStack {
                    Text("AppName").font(.largeTitle.bold()).frame(alignment: .topLeading)
                        .foregroundColor(colorScheme.getPrimaryColor())
                    Spacer().frame(width: 20)
                    
                    if (viewModel.loading) {
                        ProgressView().controlSize(.small).transition(.opacity)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "gear").renderingMode(.template).resizable().frame(width: 20, height: 20, alignment: .center).foregroundColor(colorScheme.getPrimaryColor())
                        .onTapGesture {
                            viewModel.showComingSoon()
                        }
                        .hidden()
                    
                    Spacer().frame(width: 20)
                    Image(systemName: "info.circle").renderingMode(.template).resizable().frame(width: 20, height: 20, alignment: .center).foregroundColor(colorScheme.getPrimaryColor())
                        .onTapGesture {
                            mainNavigator.navigateTo(page: .About)
                        }
                    Spacer().frame(width: 16)
                }.frame(height: 60)
                
                if (viewModel.hasSelctedFolder) {
                    ZStack {
                        contentView()
                            .performDrop(isTargeted: $isDropTarget) { provider, _ in
                                viewModel.performDrop(providers: provider)
                            }
                        if (isDropTarget) {
                            DropHintView(isTargeted: $isDropTarget)
                        }
                    }.transition(AnyTransition.asymmetric(insertion: .offset(x: -300, y: 0), removal: .offset(x: 300, y: 0)).combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
                } else {
                    emptyView().transition(AnyTransition.asymmetric(insertion: .offset(x: 300, y: 0), removal: .offset(x: -300, y: 0)).combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
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
            
            if (viewModel.showDialog) {
                if (viewModel.mediaFolderToCustom != nil) {
                    Dialog {
                        TidyOperationDialog(viewModel: viewModel, mediaFolder: viewModel.mediaFolderToCustom!)
                    }.environmentObject(viewModel).zIndex(50).transition(.opacity)
                }
            }
            
            VStack {
                Spacer().frame(height: 30)
                ToastView().environmentObject(viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }.mainPageFrame().zIndex(100)
        }.mainPageFrame()
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
                
                ActionButton(title: "AddMoreButton", icon: "folder.badge.plus",
                             foregroundColor: colorScheme.getOnSecondaryColor(),
                             backgroundColor: colorScheme.getSecondaryColor().opacity(0.8),
                             adaptOnUISizeClassChanged: true) {
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
