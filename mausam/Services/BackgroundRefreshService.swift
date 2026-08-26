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
            byAdding: .hour,
            value: 4,
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
            let weather = try await WeatherService().forecast(
                latitude: city.latitude,
                longitude: city.longitude,
                timezone: city.timezone
            )
            let now = Date()
            let eightHoursFromNow = now.addingTimeInterval(8 * 60 * 60)
            
            let rainyHours = weather.hourly.filter{ hour in
                hour.date >= now &&
                hour.date < eightHoursFromNow &&
                hour.isRainExpected
            }
            
            guard !rainyHours.isEmpty else {
                print("No rain epected in the next 8 hours")
                return
            }
            
            try await NotificationService()
                .scheduleRainNotification(for: city, rainyHours: rainyHours)

        } catch {
            print("Background weather refresh failed: \(error)")
        }
    }
}
