import SwiftUI
import Combine

struct AddCityView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @State private var cityName = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter city name", text: $cityName)
                    .disabled(viewModel.isAddingCity)

                // по нажатию проверяем через API и сохраняем в SwiftData
                Button(action: { Task { await viewModel.addCity(name: cityName) } }) {
                    HStack {
                        Text("Save")
                        if viewModel.isAddingCity {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.9)
                        }
                    }
                }
                .disabled(viewModel.isAddingCity || cityName.trimmingCharacters(in: .whitespaces).isEmpty)
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
