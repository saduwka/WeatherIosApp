import Foundation

enum TemperatureUnit: String, Codable, CaseIterable {
    case celsius = "C"
    case fahrenheit = "F"
}

protocol AppSettingsProtocol {
    var temperatureUnit: TemperatureUnit { get set }
    var lastOpenedCityName: String? { get set }
    var showCityAtStart: Bool { get set }
}

// все ключи UserDefaults в одном месте чтобы не путаться
private enum AppSettingsKey {
    static let temperatureUnit = "app.temperatureUnit"
    static let lastOpenedCityName = "app.lastOpenedCityName"
    static let showCityAtStart = "app.showCityAtStart"
}

class AppSettingsService: AppSettingsProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var temperatureUnit: TemperatureUnit {
        get {
            guard let raw = defaults.string(forKey: AppSettingsKey.temperatureUnit),
                  let unit = TemperatureUnit(rawValue: raw) else { return .celsius }
            return unit
        }
        set {
            defaults.set(newValue.rawValue, forKey: AppSettingsKey.temperatureUnit)
        }
    }

    var lastOpenedCityName: String? {
        get { defaults.string(forKey: AppSettingsKey.lastOpenedCityName) }
        set { defaults.set(newValue, forKey: AppSettingsKey.lastOpenedCityName) }
    }

    var showCityAtStart: Bool {
        get {
            if defaults.object(forKey: AppSettingsKey.showCityAtStart) == nil {
                return false
            }
            return defaults.bool(forKey: AppSettingsKey.showCityAtStart)
        }
        set {
            defaults.set(newValue, forKey: AppSettingsKey.showCityAtStart)
        }
    }
}
