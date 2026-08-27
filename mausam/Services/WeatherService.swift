//
//  WeatherService.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation

struct WeatherService {
    private let apiClient = WeatherAPIClient()
    
    private func symbolName(for weatherCode: Int) -> String {
        switch weatherCode {
        case 0:
            return "sun.max.fill"
        case 1, 2:
            return "cloud.sun.fill"
        case 3:
            return "cloud.fill"
        case 45, 48:
            return "cloud.fog.fill"
        case 51, 53, 55, 56, 57:
            return "cloud.drizzle.fill"
        case 61, 63, 65, 66, 67, 80, 81, 82:
            return "cloud.rain.fill"
        case 71, 73, 75, 77, 85, 86:
            return "cloud.snow.fill"
        case 95, 96, 99:
            return "cloud.bolt.rain.fill"
        default:
            return "cloud.fill"
        }
    }

    func forecast(latitude: Double, longitude: Double, timezone: String) async throws
        -> WeatherForecast
    {
        let response = try await apiClient.fetchWeather(
            latitude: latitude,
            longitude: longitude,
            timezone: timezone
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: timezone)
        let now = Date()
        let twentyFourHoursFromNow = now.addingTimeInterval(24 * 60 * 60)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: timezone) ?? .current
        
        let currentWeather = CurrentWeather(temperature: response.current.temperature, apparentTemperature: response.current.apparentTemperature, cloudCover: Int(response.current.cloudCover.rounded()), weatherCode: response.current.weatherCode)
        
        let hourly: [HourlyWeather] = response.hourly.time.indices.compactMap {index -> HourlyWeather? in
            guard
                let date = dateFormatter.date(from: response.hourly.time[index]),
                date >= now && date < twentyFourHoursFromNow,
                response.hourly.temperatures.indices.contains(index),
                response.hourly.precipitationProbabilities.indices.contains(index),
                response.hourly.precipitationAmounts.indices.contains(index),
                response.hourly.weatherCodes.indices.contains(index)
            
            else {
                return nil
            }
            return HourlyWeather (
                date: date,
                symbolName: symbolName(for: response.hourly.weatherCodes[index]),
                temperature: response.hourly.temperatures[index].rounded(),
                precipitationProbability: Int(response.hourly.precipitationProbabilities[index].rounded()),
                precipitationAmount: response.hourly.precipitationAmounts[index],
                isCurrentHour: calendar.isDate(date, equalTo: now, toGranularity: .hour)
            )
        }
        return WeatherForecast(current: currentWeather, hourly: hourly)
    }
}
