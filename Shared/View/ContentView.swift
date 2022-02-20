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
                
                Image(systemName: "gear").renderingMode(.template).resizable().frame(width: 20, height: 20, alignment: .center).foregroundColor(colorScheme.getPrimaryColor())
                    .hidden()
                    .onTapGesture {
                        mainNavigator.navigateTo(page: .Settings)
                    }
                
                VStack {
                    if (viewModel.toastText != nil) {
                        Text(viewModel.toastText!).foregroundColor(.black)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Color.white))
                            .addShadow()
                            .transition(.move(edge: .trailing))
                    }
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)).frame(height: 60, alignment: .trailing).clipped()
                
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
                    }).padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 12))
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
                
                ActionButton(title: "ClearButton", icon: "xmark", foregroundColor: colorScheme.getBodyTextColor(), backgroundColor: colorScheme.getPrimaryComplementaryColor()) {
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

struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var folder: MediaFolder
    @State var byKind = true
    @State var byDate = false

    var onClickRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(folder.displayName)
                    .font(.title2.bold())
                    .foregroundColor(colorScheme.getPrimaryColor())
                Image(systemName: "trash")
                    .onTapGesture {
                        onClickRemove()
                    }
            }
                        
            Text("PathTitle")
                .font(.body.bold())
                .foregroundColor(colorScheme.getPrimaryColor())
            
            Text(folder.selectedFolderURL.absoluteString.removingPercentEncoding ?? "")
            
            Text("OperationTitle")
                .font(.body.bold())
                .foregroundColor(colorScheme.getPrimaryColor())
            
            Text("OperationByKindDesc")
            
            if (folder.mediaInfos.isEmpty) {
                Text("NoMediaFound")
            } else {
                ForEach($folder.mediaInfos) { $info in
                    HStack(alignment: .center) {
                        Toggle(info.mediaExtension.uppercased(), isOn: $info.isSelected)
                            .toggleStyle(CustomToggleStyle()).background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(colorScheme.getOnSurfaceColor()))

                        Text("\(String(info.urls.count))ItemsText")
                        
                        Spacer()
                        HStack {
                            if (info.action == .Group) {
                                Image(systemName: "folder")
                            } else {
                                Image(systemName: "trash")
                            }
                            Text(info.action.toString())
                        }.padding(6).background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(colorScheme.getOnSurfaceColor().opacity(0.5)))
                    }.frame(width: nil, height: nil, alignment: .leading)
                    
                    if (folder.mediaInfos.last?.id != info.id) {
                        Divider().foregroundColor(colorScheme.getDividerColor()).opacity(0.3)
                    }
                }
            }
        }.padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(colorScheme.getSurfaceColor()).addShadow())
    }
}

struct CustomToggleStyle: ToggleStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle").renderingMode(.template).foregroundColor(colorScheme.getPrimaryColor())
            configuration.label
        }.padding(4).onTapGesture {
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
