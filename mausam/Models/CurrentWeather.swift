//
//  CurrentWeather.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct CurrentWeather {
    let temperature: Double
}

extension CurrentWeather {
    var temperatureFahrenheit: Double {
        temperature * 9 / 5 + 32
    }
}
