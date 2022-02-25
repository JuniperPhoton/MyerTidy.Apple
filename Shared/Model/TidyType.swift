//
//  TidyType.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/2/25.
//

import Foundation
import SwiftUI

protocol TidyType {
    associatedtype Input
    associatedtype GroupKey
    
    func getGroupKey(input: Input) -> GroupKey
    func getLocalizedName() -> LocalizedStringKey
}

class URLTidyType: TidyType, Identifiable, Equatable {
    static func == (lhs: URLTidyType, rhs: URLTidyType) -> Bool {
        return lhs.id == rhs.id
    }
    
    func getGroupKey(input: URL) -> String? {
        return nil
    }
    
    func getLocalizedName() -> LocalizedStringKey {
        return LocalizedStringKey("")
    }
    
    typealias Input = URL
    
    typealias GroupKey = String?
}

class EmptyTidyType: URLTidyType {
    override func getLocalizedName() -> LocalizedStringKey {
        return LocalizedStringKey("OperationMore")
    }
}

class FileAttrsTidyType: URLTidyType {
    typealias GetAttributeKey = ()-> FileAttributeKey
    typealias GetAttributeValue = (Any)-> GroupKey?
    
    private var getAttributeKey: GetAttributeKey? = nil
    private var getAttributeValue: GetAttributeValue? = nil
    private var getName: (() -> LocalizedStringKey)? = nil
    
    init(getKey: @escaping GetAttributeKey, getValue: @escaping GetAttributeValue, getName: (@escaping () -> LocalizedStringKey)) {
        self.getAttributeKey = getKey
        self.getAttributeValue = getValue
        self.getName = getName
    }
    
    override func getGroupKey(input: URL) -> String? {
        do {
            print("begin getGroupKey \(input)")
            let attrs = try FileManager.default.attributesOfItem(atPath: input.path)
                        
            guard let key = getAttributeKey?() else {
                return nil
            }
            
            guard let value = attrs[key] else {
                return nil
            }
            
            return getAttributeValue?(value) ?? nil
        } catch {
            print("getGroupKey error:  \(error)")
        }
        
        return nil
    }
    
    override func getLocalizedName() -> LocalizedStringKey {
        return getName?() ?? LocalizedStringKey("untitled")
    }
}

class FileExtensionTidyType: URLTidyType {
    override func getGroupKey(input: URL) -> String? {
        return input.pathExtension
    }
    
    override func getLocalizedName() -> LocalizedStringKey {
        return LocalizedStringKey("OperationByKindTitle")
    }
}

class FileCreationDayTidyType: FileAttrsTidyType {
    init() {
        super.init(getKey: {
            return FileAttributeKey.creationDate
        }) { date in
            guard let date = date as? Date else {
                return nil
            }
            
            return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        } getName: {
            LocalizedStringKey("OperationByCreationDayTitle")
        }
    }
}


class FileModifyDayTidyType: FileAttrsTidyType {
    init() {
        super.init(getKey: {
            return FileAttributeKey.modificationDate
        }) { date in
            guard let date = date as? Date else {
                return nil
            }
            
            return String(Calendar.current.component(.day, from: date))
        } getName: {
            LocalizedStringKey("OperationByModifiedDayTitle")
        }
    }
}
