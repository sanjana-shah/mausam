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
    let temperature: Int
    let precipitationProbability: Int
    let precipitationAmount: Double
    let isCurrentHour: Bool

    var id: Date {
        date
    }
    
    var isRainExpected: Bool {
        precipitationProbability > 0 || precipitationAmount > 0
    }
}
