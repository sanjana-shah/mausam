//
//  CitySearchView.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import SwiftUI

struct CitySearchView: View {
    let onCitySelected: (CitySearchResult) -> Void
    @State private var searchText = ""
    @State private var results: [CitySearchResult] = []
    @State private var isSearching = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            TextField("Search for a city", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()

            Button("Search") {
                Task {
                    await searchCities()
                }
            }
            .disabled(
                searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
            )

            if isSearching {
                ProgressView("Searching...")
            } else if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else {
                List(results) { city in
                    Button {
                        onCitySelected(city)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(city.name).font(.headline)

                            Text(city.country).font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }.buttonStyle(.plain)

                }.listStyle(.plain)
            }
        }.padding()
    }

    private func searchCities() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return
        }

        isSearching = true
        errorMessage = nil

        do {
            results = try await GeocodingService().searchCities(matching: query)
        } catch {
            errorMessage = "Unable to search for cities"
        }

        isSearching = false
    }
}

#Preview {
    CitySearchView { selectedCity in
        print("Selected City: \(selectedCity.name)")
    }
}
