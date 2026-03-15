import Foundation

protocol CitiesServiceProtocol {
    func loadCities() -> [City]
}

class MockCitiesService: CitiesServiceProtocol {
    func loadCities() -> [City] {
        return [
            City(name: "Astana"),
            City(name: "Berlin"),
            City(name: "Seoul")
        ]
    }
}
