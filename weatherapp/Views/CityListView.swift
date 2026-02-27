import SwiftUI

struct CityListView: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List(viewModel.cities) { city in
                Button(action: { viewModel.path.append(.cityDetails(city)) }) {
                    Text(city.name).font(.headline)
                }
            }
            .navigationTitle("Weather")
            .toolbar {
                Button(action: { viewModel.isShowingAddCity = true }) {
                    Image(systemName: "plus")
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .cityDetails(let city):
                    CityDetailView(city: city, weatherService: viewModel.weatherService)
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddCity) {
                AddCityView(viewModel: viewModel)
            }
        }
    }
}
