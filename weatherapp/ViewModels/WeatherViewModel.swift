import SwiftUI
import Combine

enum Route: Hashable {
    case cityDetails(City)
}

class WeatherViewModel: ObservableObject {
    @Published var cities: [City] = []
    @Published var path: [Route] = []
    @Published var isShowingAddCity = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published private(set) var isAddingCity = false
    @Published var isShowingSettings = false

    let weatherService: WeatherServiceProtocol
    private let citiesStorage: CitiesStorageProtocol
    var appSettings: AppSettingsProtocol

    init(citiesStorage: CitiesStorageProtocol, weatherService: WeatherServiceProtocol, appSettings: AppSettingsProtocol) {
        self.citiesStorage = citiesStorage
        self.weatherService = weatherService
        self.appSettings = appSettings
        // при старте грузим города из SwiftData
        loadCitiesFromStorage()
    }

    private func loadCitiesFromStorage() {
        do {
            cities = try citiesStorage.fetchCities()
        } catch {
            cities = []
        }
    }

    func refreshCities() {
        loadCitiesFromStorage()
    }

    func addCity(name: String) async {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if trimmedName.isEmpty {
            alertMessage = "City name cannot be empty."
            showAlert = true
            return
        }

        isAddingCity = true
        defer { isAddingCity = false }

        do {
            // сначала проверяем что город есть в API
            _ = try await weatherService.fetchWeather(for: trimmedName, units: appSettings.temperatureUnit)
            let newCity = City(name: trimmedName)
            try citiesStorage.saveCity(newCity)
            refreshCities()
            isShowingAddCity = false
        } catch let error as WeatherError {
            alertMessage = error.errorDescription ?? "Something went wrong. Please try again."
            showAlert = true
        } catch let error as CitiesStorageError {
            alertMessage = error.errorDescription ?? "Failed to save city."
            showAlert = true
        } catch {
            alertMessage = WeatherError.unknown.errorDescription ?? "Something went wrong. Please try again."
            showAlert = true
        }
    }

    /// запоминаем какой город открыли (для настройки "открыть при старте")
    func didOpenCity(_ city: City) {
        appSettings.lastOpenedCityName = city.name
    }

    func deleteCity(_ city: City) {
        do {
            try citiesStorage.deleteCity(id: city.id)
            refreshCities()
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
