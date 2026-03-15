import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        Form {
            Section("Temperature") {
                Picker("Unit", selection: Binding(
                    get: { viewModel.appSettings.temperatureUnit },
                    set: { viewModel.appSettings.temperatureUnit = $0 }
                )) {
                    Text("Celsius (°C)").tag(TemperatureUnit.celsius)
                    Text("Fahrenheit (°F)").tag(TemperatureUnit.fahrenheit)
                }
                .pickerStyle(.segmented)
            }
            Section("Startup") {
                Toggle("Open last viewed city at start", isOn: Binding(
                    get: { viewModel.appSettings.showCityAtStart },
                    set: { viewModel.appSettings.showCityAtStart = $0 }
                ))
            }
        }
        .navigationTitle("Settings")
    }
}
