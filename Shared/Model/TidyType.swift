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
    
    private var getAttributeKey: GetAttributeKey
    private var getAttributeValue: GetAttributeValue
    private var getName: (() -> LocalizedStringKey)
    
    init(getKey: @escaping GetAttributeKey, getValue: @escaping GetAttributeValue, getName: (@escaping () -> LocalizedStringKey)) {
        self.getAttributeKey = getKey
        self.getAttributeValue = getValue
        self.getName = getName
    }
    
    override func getGroupKey(input: URL) -> String? {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: input.path)
                        
            let key = getAttributeKey()
            
            guard let value = attrs[key] else {
                return nil
            }
            
            return getAttributeValue(value) ?? nil
        } catch {
            print("getGroupKey error:  \(error)")
        }
        
        return nil
    }
    
    override func getLocalizedName() -> LocalizedStringKey {
        return getName()
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
            
            return "\(date.get(.year))-\(date.get(.month))-\(date.get(.day))"
        } getName: {
            LocalizedStringKey("OperationByCreationDayTitle")
        }
    }
}

class FileCreationMonthTidyType: FileAttrsTidyType {
    init() {
        super.init(getKey: {
            return FileAttributeKey.creationDate
        }) { date in
            guard let date = date as? Date else {
                return nil
            }
            
            return "\(date.get(.year))-\(date.get(.month))"
        } getName: {
            LocalizedStringKey("OperationByCreationMonthTitle")
        }
    }
}

class FileCreationYearTidyType: FileAttrsTidyType {
    init() {
        super.init(getKey: {
            return FileAttributeKey.creationDate
        }) { date in
            guard let date = date as? Date else {
                return nil
            }
            
            return "\(date.get(.year))"
        } getName: {
            LocalizedStringKey("OperationByCreationYearTitle")
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

class ImageExifTidyType: URLTidyType {
    typealias GetExifValue = (Dictionary<String, Any>)-> GroupKey?
    
    private var getExifValue: GetExifValue
    private var getName: (() -> LocalizedStringKey)
    
    init(getValue: @escaping GetExifValue, getName: @escaping (() -> LocalizedStringKey)) {
        self.getExifValue = getValue
        self.getName = getName
    }
    
    override func getGroupKey(input: URL) -> String? {
        let data = NSData(contentsOf: input)!
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) else {
            return nil
        }
        let map = metadata as! Dictionary<String, Any>
        print("===begin")
        print(map)
        return getExifValue(map) ?? nil
    }
    
    override func getLocalizedName() -> LocalizedStringKey {
        return getName()
    }
}

class ExifColorModelTidyType: ImageExifTidyType {
    init() {
        super.init { map in
            return map["ColorModel"] as? String
        } getName: {
            LocalizedStringKey(stringLiteral: "ColorModel")
        }
    }
}

class ExifFNumberTidyType: ImageExifTidyType {
    init() {
        super.init { map in
            guard let exifMap = map["{Exif}"] as? Dictionary<String, Any> else {
                return nil
            }
            return "f/\(String(exifMap["FNumber"] as! Double))"
        } getName: {
            LocalizedStringKey(stringLiteral: "FNumber")
        }
    }
}

class ExifPortraitTidyType: ImageExifTidyType {
    init() {
        super.init { map in
            let width = map["PixelWidth"] as? Double ?? 0
            let height = map["PixelHeight"] as? Double ?? 0
            if (width == height) {
                return "Square"
            }
            return width > height ? "Landscape" : "Portrait"
        } getName: {
            LocalizedStringKey(stringLiteral: "Ratio")
        }
    }
}

class ExifModelTidyType: ImageExifTidyType {
    init() {
        super.init { map in
            guard let exifMap = map["{TIFF}"] as? Dictionary<String, Any> else {
                return nil
            }
            return "\(exifMap["Make"] as? String ?? "") \(exifMap["Model"] as? String ?? "")"
        } getName: {
            LocalizedStringKey(stringLiteral: "Model")
        }
    }
}
