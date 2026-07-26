//
//  HourlyWeatherItemView.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import SwiftUI

struct HourlyWeatherItemView: View {
    let weather: HourlyWeather

    var body: some View {
        VStack(spacing: 10) {
            if weather.isCurrentHour {
                Text("Now").font(.subheadline)
            } else {
                Text(weather.date, format: .dateTime.hour()).font(.subheadline)
            }
            Image(systemName: weather.symbolName)
                .font(.title2)
                .frame(width: 28, height: 28)
            Text("\(weather.temperature) °").font(.headline)

        }
        .frame(width: 65, height: 88, alignment: .top)
    }
}

#Preview {
    HourlyWeatherItemView(
        weather: HourlyWeather(
            date: .now,
            symbolName: "sun.max.fill",
            temperature: 78,
            isCurrentHour: true
        )
    )
}
