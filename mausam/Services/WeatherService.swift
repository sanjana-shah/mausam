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
        
        let cityTimeZone = TimeZone(identifier: timezone) ?? .gmt
        var calendar = Calendar.current
        calendar.timeZone = cityTimeZone

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = cityTimeZone
        let dailyDateFormatter = DateFormatter()
        dailyDateFormatter.dateFormat = "yyyy-MM-dd"
        dailyDateFormatter.timeZone = cityTimeZone
        let now = Date()
        let currentCityHour = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        let twentyFourHoursFromNow = calendar.date(
            byAdding: .hour,
            value: 24,
            to: currentCityHour
        ) ?? currentCityHour.addingTimeInterval(24 * 60 * 60)
        
        let currentWeather = CurrentWeather(temperature: response.current.temperature, apparentTemperature: response.current.apparentTemperature, cloudCover: Int(response.current.cloudCover.rounded()), weatherCode: response.current.weatherCode)
        
        let hourly: [HourlyWeather] = response.hourly.time.indices.compactMap {index -> HourlyWeather? in
            guard
                let date = dateFormatter.date(from: response.hourly.time[index]),
                date >= currentCityHour && date < twentyFourHoursFromNow,
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
        }.prefix(8).map{$0}
        
        let daily: [DailyWeather] = response.daily.time.indices.compactMap {index -> DailyWeather? in
            guard
                let date = dailyDateFormatter.date(from: response.daily.time[index]),
                response.daily.temperaturesMax.indices.contains(index),
                response.daily.temperaturesMin.indices.contains(index),
                response.daily.precipitationProbabilitiesMax.indices.contains(index)
            else {
                return nil
            }
            return DailyWeather (
                date: date,
                temperatureMin: response.daily.temperaturesMin[index].rounded(),
                temperatureMax: response.daily.temperaturesMax[index].rounded(),
                precipitationProbabilityMax: Int(response.daily.precipitationProbabilitiesMax[index].rounded()),
            )
        }.prefix(8).map{$0}
        
        return WeatherForecast(current: currentWeather, hourly: hourly, daily: daily)
    }
}
