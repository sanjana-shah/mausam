//
//  HourlyForecastView.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import SwiftUI

struct HourlyForecastView: View {
    let hourlyWeather: [HourlyWeather]
    var body: some View {
        VStackLayout(alignment: .leading, spacing: 12) {
            Text("Hourly Forecast").font(.headline)
        }
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach (hourlyWeather) {weather in
                    HourlyWeatherItemView(weather: weather)
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
                isCurrentHour: true
            ),
            HourlyWeather(
                date: Date(timeIntervalSinceNow: 3600),
                symbolName: "sun.max.fill",
                temperature: 74,
                isCurrentHour: false
            ),
            HourlyWeather(
                date: Date(timeIntervalSinceNow: 3600*2),
                symbolName: "cloud.sun.fill",
                temperature: 75,
                isCurrentHour: false
            ),
            HourlyWeather(
                date: Date(timeIntervalSinceNow: 3600*3),
                symbolName: "cloud.rain.fill",
                temperature: 71,
                isCurrentHour: false
            ),
        ]
    )
}
