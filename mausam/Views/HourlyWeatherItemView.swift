//
//  HourlyWeatherItemView.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import SwiftUI

struct HourlyWeatherItemView: View {
    let weather: HourlyWeather
    let timezone: TimeZone
    
    private var hourText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        formatter.timeZone = timezone
        return formatter.string(from: weather.date)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if weather.isCurrentHour {
                Text("Now").font(.subheadline)
            } else {
                Text(hourText).font(.subheadline)
            }
            Image(systemName: weather.symbolName)
                .font(.title2)
                .frame(width: 28, height: 28)
            Text("\(Int(weather.temperature.rounded())) ℃").font(.headline)
            Text(
                "\(Int(weather.temperatureFahrenheit.rounded())) ℉"
            ).font(.subheadline)

        }
        .frame(width: 65, height: 140, alignment: .top)
    }
}

#Preview {
    HourlyWeatherItemView(
        weather: HourlyWeather(
            date: .now,
            symbolName: "sun.max.fill",
            temperature: 78,
            precipitationProbability: 0,
            precipitationAmount: 0,
            isCurrentHour: true
        ),
        timezone: TimeZone(identifier: "America/New_York") ?? .gmt
    )
}
