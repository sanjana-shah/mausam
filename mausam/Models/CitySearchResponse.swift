//
//  CitySearchResponse.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct CitySearchResponse: Decodable {
    let results: [CitySearchResult]?
}

struct CitySearchResult: Codable, Identifiable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    
    static let newYork = CitySearchResult(
        id: 5_128_581,
        name: "New York",
        latitude: 40.7128,
        longitude: -74.0060,
        country: "United States"
    )
}
