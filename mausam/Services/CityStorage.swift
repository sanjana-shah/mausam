//
//  CityStorage.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct CityStorage {
    private static let selectedCityKey = "selectedCity"
    
    static func save(_ city:CitySearchResult) {
        do {
            let data = try JSONEncoder().encode(city)
            UserDefaults.standard.set(data, forKey: selectedCityKey)
        } catch {
            print("Unable to save selected city: \(error)")
        }
    }
    
    static func load() -> CitySearchResult? {
        guard let data = UserDefaults.standard.data(forKey: selectedCityKey) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(CitySearchResult.self, from: data)
        } catch {
            print("Unable to load selected city: \(error)")
            return nil
        }
    }
}
