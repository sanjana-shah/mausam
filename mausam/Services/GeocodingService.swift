//
//  GeocodingService.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct GeocodingService {
    private let apiCient = GeocodingAPIClient()
    func searchCities(
        matching query: String
    ) async throws -> [CitySearchResult] {
        let response = try await apiCient.searchCities(
            matching: query
        )

        return response.results ?? []

    }
}
