import Foundation
import SwiftUI
import Combine

@MainActor
final class CityDetailViewModel: ObservableObject {
    @Published private(set) var weather: Weather?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let weatherService: WeatherServiceProtocol

    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }

    func loadWeather(for cityName: String) async {
        isLoading = true
        errorMessage = nil

        do {
            weather = try await weatherService.fetchWeather(for: cityName)
        } catch let error as WeatherError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = WeatherError.unknown.errorDescription
        }

        isLoading = false
    }
}
