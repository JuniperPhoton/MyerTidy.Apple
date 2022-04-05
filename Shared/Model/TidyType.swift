//
//  TidyType.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/2/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

protocol TidyType {
    associatedtype Input
    associatedtype GroupKey
    
    func getGroupKey(input: Input) -> GroupKey
    func getLocalizedName() -> LocalizedStringKey
    func getId() -> String
}

// MARK: URLTidyType
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
    
    func getId() -> String {
        return "url"
    }
    
    typealias Input = URL
    typealias GroupKey = String?
}

// MARK: EmptyTidyType
class EmptyTidyType: URLTidyType {
    static let instance = EmptyTidyType()
    
    private override init() {
        
    }
    
    override func getLocalizedName() -> LocalizedStringKey {
        return LocalizedStringKey("OperationMore")
    }
    
    override func getId() -> String {
        return "empty"
    }
}

// MARK: FileAttrsTidyType
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
    
    override func getId() -> String {
        return "file_attrs"
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

// MARK: FileExtensionTidyType
class FileExtensionTidyType: URLTidyType {
    static let instance = FileExtensionTidyType()
    
    private override init() {
        
    }
    
    override func getGroupKey(input: URL) -> String? {
        return input.pathExtension
    }
    
    override func getLocalizedName() -> LocalizedStringKey {
        return LocalizedStringKey("OperationByKindTitle")
    }
    
    override func getId() -> String {
        return "file_extensions"
    }
}

// MARK: FileCreationDayTidyType
class FileCreationDayTidyType: FileAttrsTidyType {
    static let instance = FileCreationDayTidyType()
    
    private init() {
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
    
    override func getId() -> String {
        return "file_creation_day"
    }
}

// MARK: FileModificationDayTidyType
class FileModificationDayTidyType: FileAttrsTidyType {
    static let instance = FileModificationDayTidyType()
    
    private init() {
        super.init(getKey: {
            return FileAttributeKey.modificationDate
        }) { date in
            guard let date = date as? Date else {
                return nil
            }
            
            return "\(date.get(.year))-\(date.get(.month))-\(date.get(.day))"
        } getName: {
            LocalizedStringKey("OperationByModificationDayTitle")
        }
    }
    
    override func getId() -> String {
        return "file_modification_day"
    }
}

// MARK: FileModificationMonthTidyType
class FileModificationMonthTidyType: FileAttrsTidyType {
    static let instance = FileModificationMonthTidyType()
    
    private init() {
        super.init(getKey: {
            return FileAttributeKey.modificationDate
        }) { date in
            guard let date = date as? Date else {
                return nil
            }
            
            return "\(date.get(.year))-\(date.get(.month))"
        } getName: {
            LocalizedStringKey("OperationByModificationMonthTitle")
        }
    }
    
    override func getId() -> String {
        return "file_modification_month"
    }
}

// MARK: FileModificationYearTidyType
class FileModificationYearTidyType: FileAttrsTidyType {
    static let instance = FileModificationYearTidyType()
    
    private init() {
        super.init(getKey: {
            return FileAttributeKey.modificationDate
        }) { date in
            guard let date = date as? Date else {
                return nil
            }
            
            return "\(date.get(.year))"
        } getName: {
            LocalizedStringKey("OperationByModificationYearTitle")
        }
    }
    
    override func getId() -> String {
        return "file_modification_year"
    }
}

// MARK: FileCreationMonthTidyType
class FileCreationMonthTidyType: FileAttrsTidyType {
    static let instance = FileCreationMonthTidyType()
    
    private init() {
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
    
    override func getId() -> String {
        return "file_creation_month"
    }
}

// MARK: FileCreationYearTidyType
class FileCreationYearTidyType: FileAttrsTidyType {
    static let instance = FileCreationYearTidyType()
    
    private init() {
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
    
    override func getId() -> String {
        return "file_creation_year"
    }
}

// MARK: MultiTidyType
class MultiTidyType: URLTidyType {
    private let types: [URLTidyType]
    
    init(types: [URLTidyType]) {
        self.types = types
    }
    
    func getTidyType<T>() -> T {
        return types.first { type in
            type is T
        } as! T
    }
}

// MARK: ImageExifTidyType
class ImageExifTidyType: URLTidyType {
    typealias GetExifValue = (Dictionary<String, Any>)-> GroupKey?
    
    private let getExifValue: GetExifValue
    private let getName: (() -> LocalizedStringKey)
    
    init(getValue: @escaping GetExifValue, getName: @escaping (() -> LocalizedStringKey)) {
        self.getExifValue = getValue
        self.getName = getName
    }
    
    override func getGroupKey(input: URL) -> String? {
        guard let typeID = try? input.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else {
            return nil
        }
        
        guard let supertypes = UTType(typeID)?.supertypes else { return nil }
        if (!supertypes.contains(.image)) {
            return nil
        }
        
        guard let data = NSData(contentsOf: input) else {
            return nil
        }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) else {
            return nil
        }
        guard let map = metadata as? Dictionary<String, Any> else {
            return nil
        }
        Logger.logI(message: "\(map)")
        return getExifValue(map) ?? nil
    }
    
    override func getLocalizedName() -> LocalizedStringKey {
        return getName()
    }
}

// MARK: ExifColorModelTidyType
class ExifColorModelTidyType: ImageExifTidyType {
    static let instance = ExifColorModelTidyType()
    
    private init() {
        super.init { map in
            return map["ColorModel"] as? String
        } getName: {
            LocalizedStringKey("OperationByColorModel")
        }
    }
    
    override func getId() -> String {
        return "exif_color_model"
    }
}

// MARK: ExifFNumberTidyType
class ExifFNumberTidyType: ImageExifTidyType {
    static let instance = ExifFNumberTidyType()
    
    private init() {
        super.init { map in
            guard let exifMap = map["{Exif}"] as? Dictionary<String, Any> else {
                return nil
            }
            guard let fNumber = exifMap["FNumber"] as? Double else {
                return nil
            }
            return "F\(String(fNumber))"
        } getName: {
            LocalizedStringKey("OperationByFNumber")
        }
    }
    
    override func getId() -> String {
        return "exif_fnumber"
    }
}

// MARK: ExifPortraitTidyType
class ExifPortraitTidyType: ImageExifTidyType {
    static let instance = ExifPortraitTidyType()
    
    private init() {
        super.init { map in
            let width = map["PixelWidth"] as? Double ?? 0
            let height = map["PixelHeight"] as? Double ?? 0
            if (width == height) {
                return "Square"
            }
            return width > height ? "Landscape" : "Portrait"
        } getName: {
            LocalizedStringKey("OperationByRatio")
        }
    }
    
    override func getId() -> String {
        return "exif_ratio"
    }
}

// MARK: ExifModelTidyType
class ExifModelTidyType: ImageExifTidyType {
    static let instance = ExifModelTidyType()
    
    private init() {
        super.init { map in
            guard let exifMap = map["{TIFF}"] as? Dictionary<String, Any> else {
                return nil
            }
            return "\(exifMap["Make"] as? String ?? "") \(exifMap["Model"] as? String ?? "")"
        } getName: {
            LocalizedStringKey("OperationByModel")
        }
    }
    
    override func getId() -> String {
        return "exif_model"
    }
}

// MARK: AVInfoTidyType
class AVInfoTidyType: URLTidyType {
    private let getGroupKey: (AVURLAsset) -> String?
    private let getName: (() -> LocalizedStringKey)
    
    init(getGroupKey: @escaping (AVURLAsset) -> String?, getName: @escaping (() -> LocalizedStringKey)) {
        self.getGroupKey = getGroupKey
        self.getName = getName
    }
    
    override func getGroupKey(input: URL) -> String? {
        let asset = AVURLAsset(url: input)
        return getGroupKey(asset)
    }
    
    override func getLocalizedName() -> LocalizedStringKey {
        return getName()
    }
    
    override func getId() -> String {
        return "av_info"
    }
}

// MARK: AVOrientationTidyType
class AVOrientationTidyType: AVInfoTidyType {
    static let instance = AVOrientationTidyType()
    
    private init() {
        super.init { asset in
            guard let track = asset.tracks(withMediaType: .video).first else { return nil }
            let size = track.naturalSize.applying(track.preferredTransform)
            let width = abs(size.width)
            let height = abs(size.height)
            if (width == height) {
                return "Square"
            }
            return width > height ? "Landscape" : "Portrait"
        } getName: {
            LocalizedStringKey("OperationByRatio")
        }
    }
    
    override func getId() -> String {
        return "av_ratio"
    }
}

class OrientationTidyType: MultiTidyType {
    static let instance = OrientationTidyType()
    
    private init() {
        super.init(types: [ExifPortraitTidyType.instance, AVOrientationTidyType.instance])
    }
    
    override func getGroupKey(input: URL) -> String? {
        guard let typeID = try? input.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else {
            return nil
        }
        
        let type = UTType(typeID)
        if (type == .jpeg) {
            let type: ExifPortraitTidyType? = getTidyType()
            return type?.getGroupKey(input: input)
        } else if (type == .mpeg4Movie) {
            let type: AVOrientationTidyType? = getTidyType()
            return type?.getGroupKey(input: input)
        }
        
        return nil
    }
    
    override func getLocalizedName() -> LocalizedStringKey {
        return LocalizedStringKey("OperationByRatio")
    }
    
    override func getId() -> String {
        return "orientation"
    }
}
