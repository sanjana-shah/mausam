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
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text("> search city")
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.green)
                
                HStack(spacing: 0) {
                    Text("$ ").foregroundStyle(.green)
                    TextField("Search for a city", text: $searchText)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.green)
                        .tint(.green)
                        .autocorrectionDisabled()
                        .focused($isSearchFieldFocused)
                        .onSubmit {
                            Task {
                                await searchCities()
                            }
                        }
                    
                }.font(.system(.body, design: .monospaced))
                
                Button("> run search") {
                    Task {
                        await searchCities()
                    }
                }
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.cyan)
                .buttonStyle(.plain)
                .disabled(
                searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty)
            
            if isSearching {
                Text("> searching...")
                    .foregroundStyle(.green)
            } else if let errorMessage {
                Text("> error: \(errorMessage.lowercased())")
                    .foregroundStyle(.red)
            } else {
                ForEach(results) { city in
                    Button {
                        onCitySelected(city)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("> \(city.name.lowercased())")
                                .foregroundStyle(.cyan)

                            Text("  \(city.admin1.lowercased()), \(city.country.lowercased())")
                                .foregroundStyle(.green.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            }
        }.font(.system(.body, design: .monospaced))
                .padding()
        }
        .task {
            await Task.yield()
            isSearchFieldFocused = true
        }
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
