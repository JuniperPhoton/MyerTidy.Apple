//
//  Date+Get.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/2/26.
//

import Foundation

extension Date {
    func get(_ component: Calendar.Component) -> String {
        return String(Calendar.current.component(component, from: self))
    }
}
