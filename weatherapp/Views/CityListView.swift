import SwiftUI

struct CityListView: View {
    @ObservedObject var viewModel: WeatherViewModel
    let appSettings: AppSettingsProtocol
    /// открыли ли уже последний город при старте (один раз за запуск)
    @State private var didAutoOpenLastCity = false

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            // список городов из SwiftData
            List {
                ForEach(viewModel.cities) { city in
                    Button(action: {
                        viewModel.didOpenCity(city)
                        viewModel.path.append(.cityDetails(city))
                    }) {
                        Text(city.name).font(.headline)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        viewModel.deleteCity(viewModel.cities[index])
                    }
                }
            }
            .navigationTitle("Weather")
            .toolbar {
                Button(action: { viewModel.isShowingSettings = true }) {
                    Image(systemName: "gearshape")
                }
                Button(action: { viewModel.isShowingAddCity = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.isShowingSettings) {
                NavigationStack {
                    SettingsView(viewModel: viewModel)
                        .toolbar {
                            Button("Done") { viewModel.isShowingSettings = false }
                        }
                }
            }
            .onAppear {
                guard !didAutoOpenLastCity,
                      viewModel.path.isEmpty,
                      appSettings.showCityAtStart,
                      let name = appSettings.lastOpenedCityName,
                      let city = viewModel.cities.first(where: { $0.name == name })
                else { return }
                didAutoOpenLastCity = true
                viewModel.path.append(.cityDetails(city))
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .cityDetails(let city):
                    CityDetailView(city: city, weatherService: viewModel.weatherService, appSettings: appSettings)
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddCity) {
                AddCityView(viewModel: viewModel)
            }
        }
    }
}
