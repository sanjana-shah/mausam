//
//  OpenMeteoResponse.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct OpenMeteoResponse: Decodable {
    let current: CurrentWeatherResponse
}

struct CurrentWeatherResponse: Decodable {
    let temperature: Double
    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
    }
}
