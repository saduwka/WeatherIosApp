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

    let weatherService: WeatherServiceProtocol
    private let citiesService: CitiesServiceProtocol

    init(citiesService: CitiesServiceProtocol, weatherService: WeatherServiceProtocol) {
        self.citiesService = citiesService
        self.weatherService = weatherService
        self.cities = citiesService.loadCities()
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
            _ = try await weatherService.fetchWeather(for: trimmedName)
            let newCity = City(name: trimmedName)
            cities.append(newCity)
            isShowingAddCity = false
        } catch let error as WeatherError {
            alertMessage = error.errorDescription ?? "Something went wrong. Please try again."
            showAlert = true
        } catch {
            alertMessage = WeatherError.unknown.errorDescription ?? "Something went wrong. Please try again."
            showAlert = true
        }
    }
}
