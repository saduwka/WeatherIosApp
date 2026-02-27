import SwiftUI

@main
struct WeatherApp: App {
    private static let apiKey = Secrets.weatherAPIKey

    @StateObject private var viewModel: WeatherViewModel

    init() {
        let citiesService = MockCitiesService()
        let weatherService = WeatherServiceImpl(apiKey: Self.apiKey)

        _viewModel = StateObject(wrappedValue: WeatherViewModel(
            citiesService: citiesService,
            weatherService: weatherService
        ))
    }

    var body: some Scene {
        WindowGroup {
            CityListView(viewModel: viewModel)
        }
    }
}
