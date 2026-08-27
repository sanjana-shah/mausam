//
//  OpenMeteoResponse.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct OpenMeteoResponse: Decodable {
    let current: CurrentWeatherResponse
    let hourly: HourlyWeatherResponse
}

struct CurrentWeatherResponse: Decodable {
    let temperature: Double
    let apparentTemperature: Double
    let cloudCover: Double
    let weatherCode: Int
    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case cloudCover = "cloud_cover"
        case weatherCode = "weather_code"
    }
}

struct HourlyWeatherResponse: Decodable {
    let time: [String]
    let temperatures: [Double]
    let precipitationProbabilities: [Double]
    let precipitationAmounts: [Double]
    let weatherCodes: [Int]
    enum CodingKeys: String, CodingKey {
        case time
        case temperatures = "temperature_2m"
        case precipitationProbabilities = "precipitation_probability"
        case precipitationAmounts = "precipitation"
        case weatherCodes = "weather_code"
    }
}
