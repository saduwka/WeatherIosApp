import SwiftUI
import SwiftData

@main
struct WeatherApp: App {
    @StateObject private var viewModel: WeatherViewModel

    init() {
        // SwiftData для списка городов
        let schema = Schema([CityEntity.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        let modelContainer = try! ModelContainer(for: schema, configurations: [config])

        let citiesStorage = try! SwiftDataCitiesStorage(modelContainer: modelContainer)
        let appSettings = AppSettingsService()
        let secureStorage = KeychainSecureStorage()

        // API ключ из Keychain, если нет — сохраняем из Secrets
        var apiKey = try? secureStorage.readValue(for: SecureStorageKey.weatherAPIKey)
        if apiKey == nil || apiKey?.isEmpty == true {
            try? secureStorage.save(value: Secrets.weatherAPIKey, for: SecureStorageKey.weatherAPIKey)
            apiKey = try? secureStorage.readValue(for: SecureStorageKey.weatherAPIKey) ?? Secrets.weatherAPIKey
        }
        let key = apiKey ?? Secrets.weatherAPIKey

        let weatherService = WeatherServiceImpl(apiKey: key)

        _viewModel = StateObject(wrappedValue: WeatherViewModel(
            citiesStorage: citiesStorage,
            weatherService: weatherService,
            appSettings: appSettings
        ))
    }

    var body: some Scene {
        WindowGroup {
            CityListView(viewModel: viewModel, appSettings: viewModel.appSettings)
        }
    }
}
