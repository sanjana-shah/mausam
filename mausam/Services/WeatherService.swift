//
//  WeatherService.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct WeatherService {
    private let apiClient = WeatherAPIClient()

    func currentWeather(latitude: Double, longitude: Double) async throws
        -> CurrentWeather
    {
        let response = try await apiClient.fetchWeather(
            latitude: latitude,
            longitude: longitude
        )

        return CurrentWeather(temperature: response.current.temperature)
    }
}
