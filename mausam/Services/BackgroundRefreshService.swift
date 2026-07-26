//
//  BackgroundRefreshService.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import BackgroundTasks

final class BackgroundRefreshService {
    nonisolated static let taskIdentifier = "sillybilli.mausam.weather-refresh"

    nonisolated func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)

        request.earliestBeginDate = Calendar.current.date(
            byAdding: .minute,
            value: 30,
            to: Date()
        )

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background refresh request submitted")
        } catch {
            print("Could not schedule background refresh: \(error)")
        }
    }

    func performRefresh() async {
        scheduleNextRefresh()
        guard let city = CityStorage.load() else {
            print("No saved city found")
            return
        }

        do {
            let weather = try await WeatherService().currentWeather(
                latitude: city.latitude,
                longitude: city.longitude
            )
            try await NotificationService()
                .scheduleWeatherNotification(
                    for: city,
                    weather: weather
                )

        } catch {
            print("Background weather refresh failed: \(error)")
        }
    }
}
