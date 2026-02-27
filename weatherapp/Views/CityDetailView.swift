import SwiftUI

struct CityDetailView: View {
    let city: City
    @StateObject private var detailVM: CityDetailViewModel

    init(city: City, weatherService: WeatherServiceProtocol) {
        self.city = city
        _detailVM = StateObject(wrappedValue: CityDetailViewModel(weatherService: weatherService))
    }

    var body: some View {
        Group {
            if detailVM.isLoading {
                ProgressView("Loading weather…")
            } else if let error = detailVM.errorMessage {
                errorView(message: error)
            } else if let weather = detailVM.weather {
                weatherContent(weather)
            }
        }
        .navigationTitle(city.name)
        .task {
            await detailVM.loadWeather(for: city.name)
        }
    }

    // MARK: - Weather content

    private func weatherContent(_ weather: Weather) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                if let iconURL = weather.iconURL {
                    AsyncImage(url: iconURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                }

                Text("\(Int(weather.temperature))°C")
                    .font(.system(size: 64, weight: .thin))

                Text(weather.description.capitalized)
                    .font(.title2)
                    .foregroundColor(.secondary)

                HStack(spacing: 32) {
                    weatherStat(icon: "humidity", value: "\(weather.humidity)%")
                    weatherStat(icon: "wind", value: String(format: "%.1f m/s", weather.windSpeed))
                    weatherStat(icon: "cloud", value: "\(weather.cloudiness)%")
                }

                Divider()

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    detailCell(title: "Feels like", value: "\(Int(weather.feelsLike))°C")
                    detailCell(title: "Pressure", value: "\(weather.pressure) hPa")
                    detailCell(title: "Min", value: "\(Int(weather.tempMin))°C")
                    detailCell(title: "Max", value: "\(Int(weather.tempMax))°C")
                }
                .padding(.horizontal)
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Error view with retry

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button("Retry") {
                Task { await detailVM.loadWeather(for: city.name) }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Reusable components

    private func weatherStat(icon: String, value: String) -> some View {
        Label(value, systemImage: icon)
            .font(.callout)
    }

    private func detailCell(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
        }
        .frame(maxWidth: .infinity)
    }
}
