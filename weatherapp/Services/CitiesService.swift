import Foundation

protocol CitiesServiceProtocol {
    func loadCities() -> [City]
}

class MockCitiesService: CitiesServiceProtocol {
    func loadCities() -> [City] {
        return [
            City(name: "Moscow"),
            City(name: "London"),
            City(name: "New York")
        ]
    }
}
