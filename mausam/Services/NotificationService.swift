//
//  NotificationService.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import Foundation
import UserNotifications

struct NotificationService {
    private let notificationCenter = UNUserNotificationCenter.current()

    func requestPermission() async throws -> Bool {
        try await notificationCenter.requestAuthorization(
            options: [.alert, .sound, .badge]
        )
    }

    func scheduleWeatherNotification(
        for city: CitySearchResult,
        weather: CurrentWeather
    )
        async throws
    {
        let content = UNMutableNotificationContent()
        content.title = "Weather in \(city.name)"
        content.body = "It is currently \(weather.temperature.formatted()) ℃ (\(weather.temperatureFahrenheit.formatted()) ℉)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 30,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "mausam-test-notification",
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }
}
