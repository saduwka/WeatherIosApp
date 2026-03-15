import SwiftUI

// MARK: - Weather theme (colors by condition)

private enum WeatherTheme {
    static func gradient(for conditionGroup: String) -> [Color] {
        switch conditionGroup.lowercased() {
        case "clear":
            return [Color(red: 0.4, green: 0.65, blue: 0.95), Color(red: 0.6, green: 0.85, blue: 1.0)]
        case "clouds":
            return [Color(red: 0.45, green: 0.55, blue: 0.65), Color(red: 0.6, green: 0.7, blue: 0.8)]
        case "rain", "drizzle":
            return [Color(red: 0.35, green: 0.45, blue: 0.6), Color(red: 0.5, green: 0.6, blue: 0.75)]
        case "thunderstorm":
            return [Color(red: 0.25, green: 0.3, blue: 0.45), Color(red: 0.4, green: 0.45, blue: 0.6)]
        case "snow":
            return [Color(red: 0.7, green: 0.8, blue: 0.95), Color(red: 0.85, green: 0.9, blue: 1.0)]
        case "mist", "fog", "haze":
            return [Color(red: 0.6, green: 0.65, blue: 0.7), Color(red: 0.75, green: 0.78, blue: 0.82)]
        default:
            return [Color(red: 0.5, green: 0.6, blue: 0.75), Color(red: 0.65, green: 0.75, blue: 0.88)]
        }
    }

    static func accentColor(for temperature: Double) -> Color {
        if temperature < 0 { return Color(red: 0.4, green: 0.7, blue: 1.0) }
        if temperature < 15 { return Color(red: 0.5, green: 0.75, blue: 0.9) }
        return Color(red: 0.95, green: 0.6, blue: 0.2)
    }

    static func cardBackground(for conditionGroup: String) -> Color {
        switch conditionGroup.lowercased() {
        case "clear": return Color.white.opacity(0.35)
        case "snow": return Color.white.opacity(0.5)
        default: return Color.white.opacity(0.2)
        }
    }
}

struct CityDetailView: View {
    let city: City
    @StateObject private var detailVM: CityDetailViewModel

    init(city: City, weatherService: WeatherServiceProtocol) {
        self.city = city
        _detailVM = StateObject(wrappedValue: CityDetailViewModel(weatherService: weatherService))
    }

    var body: some View {
        ZStack {
            // Background gradient when we have weather data
            if let weather = detailVM.weather {
                LinearGradient(
                    colors: WeatherTheme.gradient(for: weather.conditionGroup),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }

            Group {
                if detailVM.isLoading {
                    loadingView
                } else if let error = detailVM.errorMessage {
                    errorView(message: error)
                } else if let weather = detailVM.weather {
                    weatherContent(weather)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: detailVM.isLoading)
            .animation(.easeInOut(duration: 0.4), value: detailVM.errorMessage != nil)
            .animation(.easeInOut(duration: 0.4), value: detailVM.weather != nil)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.96)),
                removal: .opacity
            ))
        }
        .navigationTitle(city.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await detailVM.loadWeather(for: city.name)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(.white)
            Text("Loading weather…")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func weatherContent(_ weather: Weather) -> some View {
        ScrollView {
            VStack(spacing: 28) {
                // Icon + temperature block
                VStack(spacing: 12) {
                    if let iconURL = weather.iconURL {
                        AsyncImage(url: iconURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                            case .failure:
                                Image(systemName: "cloud.sun.fill")
                                    .font(.system(size: 70))
                                    .foregroundStyle(.white.opacity(0.9))
                            case .empty:
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(1.2)
                            @unknown default:
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                        .frame(width: 110, height: 110)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }

                    Text("\(Int(weather.temperature))°C")
                        .font(.system(size: 68, weight: .thin))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)

                    Text(weather.description.capitalized)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.95))
                }
                .padding(.top, 20)

                // Stats row in cards
                HStack(spacing: 12) {
                    weatherStatCard(icon: "humidity.fill", value: "\(weather.humidity)%", label: "Humidity", conditionGroup: weather.conditionGroup)
                    weatherStatCard(icon: "wind", value: String(format: "%.1f m/s", weather.windSpeed), label: "Wind", conditionGroup: weather.conditionGroup)
                    weatherStatCard(icon: "cloud.fill", value: "\(weather.cloudiness)%", label: "Clouds", conditionGroup: weather.conditionGroup)
                }
                .padding(.horizontal, 16)

                // Detail grid in cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    detailCard(title: "Feels like", value: "\(Int(weather.feelsLike))°C", conditionGroup: weather.conditionGroup)
                    detailCard(title: "Pressure", value: "\(weather.pressure) hPa", conditionGroup: weather.conditionGroup)
                    detailCard(title: "Min", value: "\(Int(weather.tempMin))°C", conditionGroup: weather.conditionGroup)
                    detailCard(title: "Max", value: "\(Int(weather.tempMax))°C", conditionGroup: weather.conditionGroup)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .scrollIndicators(.hidden)
    }

    private func weatherStatCard(icon: String, value: String, label: String, conditionGroup: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white.opacity(0.95))
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(WeatherTheme.cardBackground(for: conditionGroup))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.25), lineWidth: 1)
        )
    }

    private func detailCard(title: String, value: String, conditionGroup: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
            Text(value)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(WeatherTheme.cardBackground(for: conditionGroup))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash")
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.9))

            Text(message)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundStyle(.white.opacity(0.95))
                .padding(.horizontal, 32)

            Button(action: { Task { await detailVM.loadWeather(for: city.name) } }) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white.opacity(0.95))
            .foregroundStyle(Color(red: 0.3, green: 0.45, blue: 0.65))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(red: 0.4, green: 0.5, blue: 0.65), Color(red: 0.5, green: 0.6, blue: 0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .ignoresSafeArea()
    }
}
