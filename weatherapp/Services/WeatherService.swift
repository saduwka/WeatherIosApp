import Foundation

enum WeatherError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case cityNotFound
    case unauthorized
    case tooManyRequests
    case serverError(statusCode: Int)
    case decodingError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Failed to build the request URL."
        case .networkError:
            return "No internet connection. Check your network settings and try again."
        case .cityNotFound:
            return "City not found. Please check the spelling."
        case .unauthorized:
            return "Invalid API key. Check your configuration."
        case .tooManyRequests:
            return "Too many requests. Please wait a minute and try again."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .decodingError:
            return "Failed to read weather data. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}

protocol WeatherServiceProtocol {
    func fetchWeather(for city: String) async throws -> Weather
}

final class WeatherServiceImpl: WeatherServiceProtocol {
    private let apiKey: String
    private let session: URLSession
    private let decoder: JSONDecoder

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchWeather(for city: String) async throws -> Weather {
        let url = try buildURL(for: city)
        let data = try await performRequest(url: url)
        let dto = try decodeResponse(data: data)
        return Weather(from: dto)
    }

    private func buildURL(for city: String) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "en"),
        ]

        guard let url = components.url else {
            throw WeatherError.invalidURL
        }
        return url
    }

    private func performRequest(url: URL) async throws -> Data {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WeatherError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw WeatherError.unknown
        }

        switch http.statusCode {
        case 200:
            return data
        case 401:
            throw WeatherError.unauthorized
        case 404:
            throw WeatherError.cityNotFound
        case 429:
            throw WeatherError.tooManyRequests
        case 500...599:
            throw WeatherError.serverError(statusCode: http.statusCode)
        default:
            throw WeatherError.serverError(statusCode: http.statusCode)
        }
    }

    private func decodeResponse(data: Data) throws -> WeatherResponseDTO {
        do {
            return try decoder.decode(WeatherResponseDTO.self, from: data)
        } catch {
            throw WeatherError.decodingError(error)
        }
    }
}
