//
//  ContentView.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import SwiftUI

struct ContentView: View {

    let sampleHourlyWeather: [HourlyWeather] = {

        let symbols = [
            "sun.max.fill",
            "sun.max.fill",
            "cloud.sun.fill",
            "cloud.fill",
            "cloud.rain.fill",
            "cloud.rain.fill",
            "cloud.fill",
            "cloud.sun.fill",
        ]

        let temperatures = [
            72, 74, 75, 74, 71, 69, 68, 67,
        ]

        let generatedData: [HourlyWeather] = (0..<24).compactMap { hourOffset in
            guard
                let date = Calendar.current.date(
                    byAdding: .hour,
                    value: hourOffset,
                    to: .now
                )
            else {
                return nil
            }

            return HourlyWeather(
                date: date,
                symbolName: symbols[hourOffset % symbols.count],
                temperature: temperatures[hourOffset % temperatures.count],
                isCurrentHour: hourOffset == 0
            )
        }

        return generatedData
    }()
    @State private var temperature: Double?
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
                    Text(selectedCity.name).font(.title2)
                    Button {
                        isShowingCitySearch = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.subheadline)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Change city")
                }
                DigitalClockView()
                if let temperature {
                    Text("\(Int(temperature.rounded())) ℉").font(
                        .system(size: 72, weight: .thin)
                    )
                } else {
                    ProgressView()
                }

                Text("partly cloudy").font(.title3)
                Text("H: 78 ℉  L: 64 ℉").font(.subheadline)
                HourlyForecastView(hourlyWeather: sampleHourlyWeather)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 24)

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
                                    weather: currentWeather,
                                    trigger: UNTimeIntervalNotificationTrigger(
                                        timeInterval: 30,
                                        repeats: false
                                    )
                                )
                            print("Test notification scheduled")
                        } catch {
                            print("Unable to schedule notification \(error)")
                        }

                    }
                }
            }
            .padding()
        }.sheet(isPresented: $isShowingCitySearch) {
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
        }
    }
    private func loadWeather(for city: CitySearchResult) async {
        do {
            let weather = try await WeatherService().currentWeather(
                latitude: city.latitude,
                longitude: city.longitude
            )
            currentWeather = weather
            temperature = weather.temperature
        } catch {
            print("Unable to load weather: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
