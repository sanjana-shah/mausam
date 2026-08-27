//
//  CurrentWeather.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct CurrentWeather {
    let temperature: Double
    let apparentTemperature: Double
    let cloudCover: Int
    let weatherCode: Int
}

extension CurrentWeather {
    var temperatureFahrenheit: Double {
        temperature * 9 / 5 + 32
    }
    
    var apparentTemperatureFahrenheit: Double {
        apparentTemperature * 9 / 5 + 32
    }
}
