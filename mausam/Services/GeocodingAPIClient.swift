//
//  GeocodingAPIClient.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct GeocodingAPIClient {
    func searchCities(
        matching cityName: String
    ) async throws -> CitySearchResponse {
        let encodedCityName = cityName.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        )

        guard let encodedCityName else {
            throw URLError(.badURL)
        }

        let urlString =
            "https://geocoding-api.open-meteo.com/v1/search"
            + "?name=\(encodedCityName)"
            + "&count=10"
            + "&language=en"
            + "&format=json"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(CitySearchResponse.self, from: data)
    }
}
