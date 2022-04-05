//
//  Settings.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/4/5.
//

import Foundation

class TidySettings {
    private static let KEY_OPTIONS = "key_tidy_options"
    
    private static let JSON_KEY_TIDY_OPTIONS = "tidy_options"
    private static let JSON_KEY_ID = "id"
    private static let JSON_KEY_TYPE = "type"
    private static let JSON_KEY_ENABLED = "enabled"
    private static let JSON_VALUE_TYPE_STANDARD = "standard"

    static let instance = TidySettings()
    
    static let allOptions = [
        MediaTidyOption(isSelected: true, type: FileExtensionTidyType.instance),
        MediaTidyOption(isSelected: false, type: OrientationTidyType.instance),
        MediaTidyOption(isSelected: false, type: FileCreationDayTidyType.instance),
        MediaTidyOption(isSelected: false, type: FileCreationMonthTidyType.instance),
        MediaTidyOption(isSelected: false, type: FileCreationYearTidyType.instance),
        MediaTidyOption(isSelected: false, type: FileModificationDayTidyType.instance),
        MediaTidyOption(isSelected: false, type: FileModificationMonthTidyType.instance),
        MediaTidyOption(isSelected: false, type: FileModificationYearTidyType.instance),
        MediaTidyOption(isSelected: false, type: ExifModelTidyType.instance),
        MediaTidyOption(isSelected: false, type: ExifFNumberTidyType.instance),
        MediaTidyOption(isSelected: false, type: ExifColorModelTidyType.instance),
        MediaTidyOption(isSelected: false, type: EmptyTidyType.instance),
    ]
    
    private init() {
        // empty constructor
    }
    
    func saveOptionsToSettings(options: [MediaTidyOption]) {
        var data: [NSMutableDictionary] = []
        options.forEach { o in
            if !(o.type is EmptyTidyType) {
                let dic: NSMutableDictionary = [:]
                dic[TidySettings.JSON_KEY_ID] = o.type.getId()
                dic[TidySettings.JSON_KEY_TYPE] = TidySettings.JSON_VALUE_TYPE_STANDARD
                dic[TidySettings.JSON_KEY_ENABLED] = o.isSelected
                data.append(dic)
            }
        }
        
        let json = [
            TidySettings.JSON_KEY_TIDY_OPTIONS : data
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = String(data: jsonData!, encoding: .utf8)
        Logger.logI(message: "data is \(String(describing: jsonString))")
        
        UserDefaults.standard.set(jsonString, forKey: TidySettings.KEY_OPTIONS)
    }
    
    func getSettingOptions(enabledOnly: Bool) -> [MediaTidyOption] {
        let options = UserDefaults.standard.string(forKey: TidySettings.KEY_OPTIONS)
        if (options == nil) {
            return getDefaultOptions()
        } else {
            Logger.logI(message: "read from settings: \(String(describing: options))")
            return parseFromSettingsJson(settingsJson: options!, enabledOnly: enabledOnly) ?? getDefaultOptions()
        }
    }
    
    private func parseFromSettingsJson(settingsJson: String, enabledOnly: Bool) -> [MediaTidyOption]? {
        guard let data = settingsJson.data(using: .utf8) else {
            return nil
        }
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        var result: [MediaTidyOption] = []
        
        guard let array = object[TidySettings.JSON_KEY_TIDY_OPTIONS] as? Array<Any> else {
            return nil
        }
        
        array.forEach { obj in
            let dic = obj as? [String: Any]
            if (dic != nil) {
                let option = fromJsonObject(dic: dic!)
                if (option != nil) {
                    result.append(option!)
                }
            }
        }
        
        result.append(MediaTidyOption(isSelected: false, type: EmptyTidyType.instance))
        result = result.filter { o in
            (enabledOnly ? o.isSelected : true) || o.type is EmptyTidyType
        }
        
        result.forEachIndexed { o, index in
            o.isSelected = index == 0
        }
        
        return result
    }
    
    private func getDefaultOptions() -> [MediaTidyOption] {
        return [
            MediaTidyOption(isSelected: true, type: FileExtensionTidyType.instance),
            MediaTidyOption(isSelected: false, type: OrientationTidyType.instance),
            MediaTidyOption(isSelected: false, type: FileCreationDayTidyType.instance),
            MediaTidyOption(isSelected: false, type: FileModificationDayTidyType.instance),
            MediaTidyOption(isSelected: false, type: EmptyTidyType.instance)
        ]
    }
    
    private func fromJsonObject(dic: [String: Any]) -> MediaTidyOption? {
        guard let id = dic[TidySettings.JSON_KEY_ID] as? String else {
            return nil
        }
        guard let enabled = dic[TidySettings.JSON_KEY_ENABLED] as? Bool else {
            return nil
        }
        guard let type = TidySettings.allOptions.first(where: { o in
            o.type.getId() == id
        })?.type else {
            return nil
        }
        return MediaTidyOption(isSelected: enabled, type: type)
    }
}
