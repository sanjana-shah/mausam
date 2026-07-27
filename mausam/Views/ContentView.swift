//
//  ContentView.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import SwiftUI

struct ContentView: View {

    @State private var currentWeather: CurrentWeather?
    @State private var isShowingCitySearch = false
    @State private var selectedCity: CitySearchResult

    init() {
        let initialCity = CityStorage.load() ?? CitySearchResult.newYork
        _selectedCity = State(initialValue: initialCity)
    }
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Text(selectedCity.name).font(.title)
                    Button {
                        isShowingCitySearch = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.subheadline)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Change city")
                }
                DigitalClockView(timeZoneIdentifier: selectedCity.timezone)
                if let currentWeather {
                    Text(
                        "\(Int(currentWeather.temperature.rounded())) ℃"
                    ).font(
                        .system(size: 72, weight: .thin)
                    )

                    Text(
                        "\(Int(currentWeather.temperatureFahrenheit.rounded())) ℉"
                    ).font(
                        .title
                    ).foregroundStyle(.primary)
                } else {
                    ProgressView()
                }

                Button("Test Weather Notification") {
                    Task {
                        guard let currentWeather else {
                            print("Weather not loaded yet")
                            return
                        }

                        do {
                            let permissionGranted =
                                try await NotificationService()
                                .requestPermission()
                            guard permissionGranted else {
                                print("Notification permission was denied.")
                                return
                            }

                            try await NotificationService()
                                .scheduleWeatherNotification(
                                    for: selectedCity,
                                    weather: currentWeather
                                )
                            print("Test notification scheduled")
                        } catch {
                            print("Unable to schedule notification \(error)")
                        }

                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $isShowingCitySearch) {
            CitySearchView { city in
                selectedCity = city
                CityStorage.save(city)
                isShowingCitySearch = false

                Task {
                    await loadWeather(for: city)
                }
            }
        }
        .task {
            await loadWeather(for: selectedCity)
            BackgroundRefreshService().scheduleNextRefresh()
        }
    }
    private func loadWeather(for city: CitySearchResult) async {
        do {
            let weather = try await WeatherService().currentWeather(
                latitude: city.latitude,
                longitude: city.longitude
            )
            currentWeather = weather
        } catch {
            print("Unable to load weather: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
