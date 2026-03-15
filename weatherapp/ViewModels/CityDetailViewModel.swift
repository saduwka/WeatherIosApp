import Foundation
import SwiftUI
import Combine

@MainActor
final class CityDetailViewModel: ObservableObject {
    @Published private(set) var weather: Weather?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    var temperatureUnit: TemperatureUnit { appSettings.temperatureUnit }

    private let weatherService: WeatherServiceProtocol
    private let appSettings: AppSettingsProtocol

    init(weatherService: WeatherServiceProtocol, appSettings: AppSettingsProtocol) {
        self.weatherService = weatherService
        self.appSettings = appSettings
    }

    func loadWeather(for cityName: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // единицы температуры из настроек (C или F)
            weather = try await weatherService.fetchWeather(for: cityName, units: appSettings.temperatureUnit)
        } catch let error as WeatherError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = WeatherError.unknown.errorDescription
        }

        isLoading = false
    }
}
