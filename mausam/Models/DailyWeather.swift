//
//  DailyWeather.swift
//  mausam
//
//  Created by Sanjana Shah on 8/27/26.
//

import Foundation

struct DailyWeather: Identifiable {

    let date: Date
    let temperatureMin: Double
    let temperatureMax: Double
    let precipitationProbabilityMax: Int

    var id: Date {
        date
    }
    
    var isRainExpected: Bool {
        precipitationProbabilityMax > 20
    }
    
}

extension DailyWeather {
    var temperatureMinFahrenheit: Double {
        temperatureMin * 9 / 5 + 32
    }
    
    var temperatureMaxFahrenheit: Double {
        temperatureMax * 9 / 5 + 32
    }
}
