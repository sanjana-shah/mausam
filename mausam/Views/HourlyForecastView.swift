//
//  HourlyForecastView.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import SwiftUI

struct HourlyForecastView: View {
    let hourlyWeather: [HourlyWeather]
    let timezone: TimeZone
    var body: some View {
        VStackLayout(alignment: .leading, spacing: 12) {
            Text("Hourly Forecast").font(.headline)
        }
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach (hourlyWeather) {weather in
                    HourlyWeatherItemView(weather: weather, timezone: timezone)
                }
            }
        }
    }
}

#Preview {
    HourlyForecastView(
        hourlyWeather: [
            HourlyWeather(
                date: .now,
                symbolName: "sun.max.fill",
                temperature: 72,
                precipitationProbability: 0,
                precipitationAmount: 0,
                isCurrentHour: true
            ),
            HourlyWeather(
                date: Date(timeIntervalSinceNow: 3600),
                symbolName: "sun.max.fill",
                temperature: 74,
                precipitationProbability: 0,
                precipitationAmount: 0,
                isCurrentHour: false
            ),
            HourlyWeather(
                date: Date(timeIntervalSinceNow: 3600*2),
                symbolName: "cloud.sun.fill",
                temperature: 75,
                precipitationProbability: 0,
                precipitationAmount: 0,
                isCurrentHour: false
            ),
            HourlyWeather(
                date: Date(timeIntervalSinceNow: 3600*3),
                symbolName: "cloud.rain.fill",
                temperature: 71,
                precipitationProbability: 0,
                precipitationAmount: 0,
                isCurrentHour: false
            ),
        ],
        timezone: TimeZone(identifier: "America/New_York") ?? .gmt,
    )
}
