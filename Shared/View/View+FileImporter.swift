//
//  View+FileImporter.swift
//  MyerTidy (macOS)
//
//  Created by juniperphoton on 2022/2/20.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension View {
    func importFolder(isPresented: Binding<Bool>, onSucess: @escaping ([URL])->Void) -> some View {
        self.fileImporter(isPresented: isPresented, allowedContentTypes: [UTType.folder], allowsMultipleSelection: true) { result in
            defer {
                isPresented.wrappedValue = false
            }
            switch result {
            case .success(let urls):
                onSucess(urls)
                break
            case .failure(_):
                break
            }
        }
    }
}
