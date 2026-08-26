//
//  HourlyWeather.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct HourlyWeather: Identifiable {

    let date: Date
    let symbolName: String
    let temperature: Double
    let precipitationProbability: Int
    let precipitationAmount: Double
    let isCurrentHour: Bool

    var id: Date {
        date
    }
    
    var isRainExpected: Bool {
        precipitationProbability > 20 || precipitationAmount > 0
    }
    
}

extension HourlyWeather {
    var temperatureFahrenheit: Double {
        temperature * 9 / 5 + 32
    }
}
