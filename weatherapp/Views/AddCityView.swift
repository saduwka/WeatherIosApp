import SwiftUI
import Combine

struct AddCityView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var cityName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter city name", text: $cityName)
                Button("Save") {
                    viewModel.addCity(name: cityName)
                }
            }
            .navigationTitle("New City")
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}
