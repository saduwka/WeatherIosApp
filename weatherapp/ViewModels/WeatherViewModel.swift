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

    let weatherService: WeatherServiceProtocol
    private let citiesService: CitiesServiceProtocol

    init(citiesService: CitiesServiceProtocol, weatherService: WeatherServiceProtocol) {
        self.citiesService = citiesService
        self.weatherService = weatherService
        self.cities = citiesService.loadCities()
    }

    func addCity(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if trimmedName.isEmpty {
            alertMessage = "City name cannot be empty"
            showAlert = true
            return
        }

        let newCity = City(name: trimmedName)
        cities.append(newCity)
        isShowingAddCity = false
    }
}
