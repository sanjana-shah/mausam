//
//  WeatherAPIClient.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct WeatherAPIClient {
    func fetchWeather(latitude: Double, longitude: Double) async throws
        -> OpenMeteoResponse
    {
        let urlString =
            "https://api.open-meteo.com/v1/forecast"
            + "?latitude=\(latitude)"
            + "&longitude=\(longitude)"
            + "&current=temperature_2m"
            + "&temperature_unit=fahrenheit"

        guard let url = URL(string: urlString) else {
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
