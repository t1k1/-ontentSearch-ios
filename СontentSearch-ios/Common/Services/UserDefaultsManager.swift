//
//  UserDefaultsManager.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 12.04.2024.
//

import Foundation

struct UserDefaultsService {
    static let key = "SearchHistory"
    static let shared = UserDefaultsService()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func saveSearch(_ elements: [String]) {
        userDefaults.set(elements, forKey: UserDefaultsService.key)
    }
    
    func loadSearch() -> [String] {
        guard let result = userDefaults.array(forKey: UserDefaultsService.key) as? [String] else {
            return []
        }
        return result
    }
}
