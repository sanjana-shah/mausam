//
//  ContentView.swift
//  mausam
//
//  Created by Sanjana Shah on 7/25/26.
//

import SwiftUI

struct ContentView: View {

    @State private var currentWeather: CurrentWeather?
    @State private var hourlyWeather: [HourlyWeather] = []
    @State private var dailyWeather: [DailyWeather] = []
    @State private var isShowingCitySearch = false
    @State private var selectedCity: CitySearchResult
    @State private var visibleText: [String] = []
    @State private var visibleOpeningText: [String] = []
    @State private var visibleWeeklyForecastText: [String] = []
    @State private var visibleChangeCityText: [String] = []
    @State private var hasShownWeeklyForecast = false

    init() {
        let initialCity = CityStorage.load() ?? CitySearchResult.newYork
        _selectedCity = State(initialValue: initialCity)
    }
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
        ScrollView {
            VStack(alignment: .leading, spacing: 1) {
                Text(visibleOpeningText.joined())
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(visibleText.joined())
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !visibleWeeklyForecastText.isEmpty {
                    Button(visibleWeeklyForecastText.joined()) {
                        Task {
                            await showWeeklyForecast()
                        }
                    }
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.cyan)
                    .buttonStyle(.plain)
                }
                
                if !visibleChangeCityText.isEmpty {
                    Button(visibleChangeCityText.joined()) {
                        isShowingCitySearch = true
                    }
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.cyan)
                    .buttonStyle(.plain)
                }


                Text("█")
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.green)
            }
            .padding()
        }
    }
        .sheet(isPresented: $isShowingCitySearch) {
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
            BackgroundRefreshService().scheduleNextRefresh()
        }
    }
    
    private func openingAppLines() -> [String] {
        var lines: [String] = []
        lines.append("mausam v1.0")
        lines.append("> connecting to the weather service")
        lines.append("> loading forecast for \(selectedCity.name.lowercased())...")
        return lines
    }
    
    private func animateOpeningTerminalLines() async {
        visibleOpeningText = []
        for line in openingAppLines() {
            for character in line {
                visibleOpeningText.append(String(character))
                try? await Task.sleep(for: .milliseconds(2))
            }
            visibleOpeningText.append("\n")
        }
    }
    
    private func terminalLines() -> [String] {
        var lines: [String] = []
        
        let now = Date()
        let timeZone = TimeZone(identifier: selectedCity.timezone) ?? .current
        let time = now.formatted(Date.FormatStyle(date: .omitted, time: .shortened, timeZone: timeZone))
        let abbreviation = timeZone.abbreviation(for: now) ?? selectedCity.timezone
        
        if let currentWeather {
            lines.append("> time: \(time) \(abbreviation)")
            lines.append("> current conditions")
            lines.append("  temp: \(Int(currentWeather.temperature.rounded()))C / \(Int(currentWeather.temperatureFahrenheit.rounded()))F")
            
            lines.append("  feels like: \(Int(currentWeather.apparentTemperature.rounded()))C / \(Int(currentWeather.apparentTemperatureFahrenheit.rounded()))F")
            lines.append("  cloud cover: \(currentWeather.cloudCover)%")
            lines.append("\n")
        }
        
        if !hourlyWeather.isEmpty {
            lines.append("> hourly forecast")
            for weather in hourlyWeather.prefix(8) {
                let label = getForecastLine(weather: weather)
                lines.append(label)
            }
            lines.append("\n")
        }
        return lines
    }
    
    private func hourText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        formatter.timeZone = TimeZone(identifier: selectedCity.timezone)
        return formatter.string(from: date).lowercased()
    }
    
    private func animateTerminalLines() async {
        visibleText = []
        for line in terminalLines() {
            for character in line {
                visibleText.append(String(character))
                try? await Task.sleep(for: .milliseconds(2))
            }
            visibleText.append("\n")
        }
    }

    private func animateActionButtons() async {
        visibleWeeklyForecastText = []
        visibleChangeCityText = []
        
        if !hasShownWeeklyForecast {
            for character in "> weekly-forecast" {
                visibleWeeklyForecastText.append(String(character))
                try? await Task.sleep(for: .milliseconds(2))
            }
        }
        
        for character in "> change-city" {
            visibleChangeCityText.append(String(character))
            try? await Task.sleep(for: .milliseconds(2))
        }
    }
    
    private func loadWeather(for city: CitySearchResult) async {
        do {
            let weather = try await WeatherService().forecast(
                latitude: city.latitude,
                longitude: city.longitude,
                timezone: city.timezone
            )
            clearTerminal()
            await animateOpeningTerminalLines()

            currentWeather = weather.current
            hourlyWeather = weather.hourly
            dailyWeather = weather.daily
            await animateTerminalLines()
            await animateActionButtons()
        } catch {
            print("Unable to load weather: \(error)")
        }
    }
    
    private func showWeeklyForecast() async {
        guard !hasShownWeeklyForecast, !dailyWeather.isEmpty else {
            return
        }
        
        hasShownWeeklyForecast = true
        visibleWeeklyForecastText = []
        visibleText.append("\n")
        
        for line in weeklyForecastLines() {
            for character in line {
                visibleText.append(String(character))
                try? await Task.sleep(for: .milliseconds(2))
            }
            visibleText.append("\n")
        }
    }
    
    private func clearTerminal() {
        visibleOpeningText = []
        visibleText = []
        visibleWeeklyForecastText = []
        visibleChangeCityText = []
        hasShownWeeklyForecast = false
    }
    
    private func getForecastLine(weather: HourlyWeather) -> String {
        let time = weather.isCurrentHour ? "now" : hourText(for: weather.date)
        let temperature = " \(Int(weather.temperature.rounded()))C/\(Int(weather.temperatureFahrenheit.rounded()))F"
        let rainChance = weather.isRainExpected ? " rain \(weather.precipitationProbability)%" : ""

        return "  \(time.padding(toLength: 5, withPad: " ", startingAt: 0))\(getConditionText(symbolName: weather.symbolName).padding(toLength: 7, withPad: " ", startingAt: 0))\(temperature)\(rainChance)"
    }
    
    private func getDailyForecastLines() -> [String] {
        let forecast = Array(dailyWeather.prefix(7))
        
        return [
            dailyChartRow(label: "", values: forecast.map { dayText(for: $0.date) }),
            dailyChartRow(label: "hi", values: forecast.map { "\(Int($0.temperatureMax.rounded()))C" }),
            dailyChartRow(label: "", values: forecast.map { "\(Int($0.temperatureMaxFahrenheit.rounded()))F" }),
            dailyChartRow(label: "", values: dailyHighTemperatureBars(for: forecast)),
            dailyChartRow(label: "lo", values: forecast.map { "\(Int($0.temperatureMin.rounded()))C" }),
            dailyChartRow(label: "", values: forecast.map { "\(Int($0.temperatureMinFahrenheit.rounded()))F" }),
            dailyChartRow(label: "r%", values: forecast.map { "\($0.precipitationProbabilityMax)" })
        ]
    }
    
    private func weeklyForecastLines() -> [String] {
        guard !dailyWeather.isEmpty else {
            return []
        }
        
        var lines = ["> weekly forecast"]
        lines.append(contentsOf: getDailyForecastLines())
        
        return lines
    }
    
    private func dailyChartRow(label: String, values: [String]) -> String {
        let paddedLabel = label.padding(toLength: 4, withPad: " ", startingAt: 0)
        let paddedValues = values.map { leftPad($0, toLength: 3) }.joined(separator: " ")
        
        return "\(paddedLabel)\(paddedValues)"
    }
    
    private func dayText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.timeZone = TimeZone(identifier: selectedCity.timezone)
        return formatter.string(from: date).lowercased()
    }
    
    private func dailyHighTemperatureBars(for forecast: [DailyWeather]) -> [String] {
        let levels = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
        let temperatures = forecast.map(\.temperatureMax)
        guard
            let lowestTemperature = temperatures.min(),
            let highestTemperature = temperatures.max()
        else {
            return []
        }
        
        let temperatureRange = highestTemperature - lowestTemperature
        guard temperatureRange > 0 else {
            return Array(repeating: "▄", count: forecast.count)
        }
        
        return temperatures.map { temperature in
            let scaledValue = (temperature - lowestTemperature) / temperatureRange
            let levelIndex = Int((scaledValue * Double(levels.count - 1)).rounded())
            
            return levels[levelIndex]
        }
    }
    
    private func leftPad(_ text: String, toLength length: Int) -> String {
        guard text.count < length else {
            return text
        }
        
        return String(repeating: " ", count: length - text.count) + text
    }

    
    private func getConditionText(symbolName: String) -> String {
        switch symbolName {
        case "sun.max.fill":
            return "sun"
        case "cloud.sun.fill":
            return "partly"
        case "cloud.fill":
            return "cloudy"
        case "cloud.fog.fill":
            return "fog"
        case "cloud.drizzle.fill":
            return "drizzle"
        case "cloud.rain.fill":
            return "rain"
        case "cloud.snow.fill":
            return "snow"
        case "cloud.bolt.rain.fill":
            return "storm"
        default:
            return "clouds"
        }
    }
}

#Preview {
    ContentView()
}
