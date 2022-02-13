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
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("ProjectC").font(.largeTitle.bold()).frame(maxWidth: .infinity, alignment: .topLeading)
                
                Image(systemName: "gear").renderingMode(.template).resizable().frame(width: 20, height: 20, alignment: .center).foregroundColor(Color.black)
                Spacer().frame(width: 20)
                Image(systemName: "info.circle").renderingMode(.template).resizable().frame(width: 20, height: 20, alignment: .center).foregroundColor(Color.black)
                Spacer().frame(width: 16)
            }
            
            if (viewModel.hasSelctedFolder) {
                contentView().transition(AnyTransition.asymmetric(insertion: .offset(x: -100, y: 0), removal: .offset(x: 100, y: 0)).combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
            } else {
                emptyView().transition(AnyTransition.asymmetric(insertion: .offset(x: 100, y: 0), removal: .offset(x: -100, y: 0)).combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
            }
        }.padding(24)
            .frame(minWidth: 400, minHeight: 600, alignment: .topLeading)
            .background(colorScheme == .dark ? Color(hex: 0x333232) : Color(hex: 0xfffbfe))
    }
    
    private func emptyView() -> some View {
        ZStack {
            DropAreaView { provider, location in
                return viewModel.performDrop(providers: provider)
            }
            
            VStack {
                ActionButton(title: "SELECT FOLDER", icon: "folder.badge.plus") {
                    selectFolder()
                }.addShadow()
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
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
                ActionButton(title: "TIDY UP!", icon: "wrench.and.screwdriver", matchParent: true) {
                    viewModel.performSort()
                }.addShadow()
                
                Spacer()
                
                ActionButton(title: "ADD MORE", icon: "folder.badge.plus", backgroundColor: Color(hex: 0xf6f6f6)) {
                    selectFolder()
                }.addShadow()
                
                ActionButton(title: "CLEAR", icon: "xmark", backgroundColor: Color(hex: 0xf6f6f6)) {
                    withAnimation {
                        viewModel.clear()
                    }
                }.addShadow()
            }.frame(maxWidth: .infinity)
            
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func selectFolder() {
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .miniaturizable, backing: .buffered, defer: true)
        
        folderPicker.canChooseDirectories = true
        folderPicker.canChooseFiles = false
        folderPicker.allowsMultipleSelection = true
        folderPicker.canDownloadUbiquitousContents = true
        folderPicker.canResolveUbiquitousConflicts = true
        
        folderPicker.begin { response in
            if response == .OK {
                withAnimation {
                    folderPicker.urls.forEach { url in
                        viewModel.addMediaFolder(forUrl: url)
                    }
                }
            }
        }
    }
}

struct CardView: View {
    @ObservedObject var folder: MediaFolder
    @State var byKind = true
    @State var byDate = false

    var onClickRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(folder.displayName)
                    .font(.title2.bold())
                    .foregroundColor(Color(hex: 0x6350a1))
                Image(systemName: "trash")
                    .onTapGesture {
                        onClickRemove()
                    }
            }
                        
            Text("PATH")
                .font(.body.bold())
                .foregroundColor(Color(hex: 0x6350a1))
            
            Text(folder.selectedFolderURL.absoluteString.removingPercentEncoding ?? "")
            
            Text("OPEREATION")
                .font(.body.bold())
                .foregroundColor(Color(hex: 0x6350a1))
            
            if (folder.mediaInfos.isEmpty) {
                Text("No media info found")
            } else {
                ForEach($folder.mediaInfos) { $info in
                    HStack(alignment: .center) {
                        Toggle(info.mediaExtension.uppercased(), isOn: $info.isSelected)
                            .toggleStyle(CustomToggleStyle()).background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(hex: 0xe6def7)))
                        Text("\(info.urls.count) items")
                        
                        Spacer()
                        HStack {
                            if (info.action == .Group) {
                                Image(systemName: "folder")
                            } else {
                                Image(systemName: "trash")
                            }
                            Text("\(info.action.toString())")
                        }.padding(6).background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(hex: 0xe6def7).opacity(0.5)))
                    }.frame(width: nil, height: nil, alignment: .leading)
                    if (folder.mediaInfos.last?.id != info.id) {
                        Divider().foregroundColor(Color(hex: 0xf3dbe4)).opacity(0.3)
                    }
                }
            }
        }.padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color(hex: 0xf2edf7)).addShadow())
    }
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle").renderingMode(.template).foregroundColor(Color(hex: 0x6350a1))
            configuration.label
        }.padding(4).onTapGesture {
            configuration.isOn.toggle()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
