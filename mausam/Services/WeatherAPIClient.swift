//
//  WeatherAPIClient.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct WeatherAPIClient {
    func fetchWeather(latitude: Double, longitude: Double, timezone: String) async throws
        -> OpenMeteoResponse
    {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,cloud_cover,weather_code"),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "hourly", value: "temperature_2m,precipitation_probability,precipitation,weather_code"),
            URLQueryItem(name: "forecast_days", value: "2"),
            URLQueryItem(name: "timezone", value: timezone),
            ]
        

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse
        else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            OpenMeteoResponse.self,
            from: data
        )
    }
}
