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
    let isCurrentHour: Bool

    var id: Date {
        date
    }
}
