import Foundation

struct WeatherResponseDTO: Decodable {
    let coord: CoordDTO
    let weather: [WeatherConditionDTO]
    let main: MainDTO
    let visibility: Int?
    let wind: WindDTO?
    let clouds: CloudsDTO?
    let dt: TimeInterval
    let sys: SysDTO?
    let timezone: Int
    let name: String
}

struct CoordDTO: Decodable {
    let lon: Double
    let lat: Double
}

struct WeatherConditionDTO: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainDTO: Decodable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

struct WindDTO: Decodable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

struct CloudsDTO: Decodable {
    let all: Int
}

struct SysDTO: Decodable {
    let country: String?
    let sunrise: TimeInterval?
    let sunset: TimeInterval?
}

struct Weather {
    let temperature: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    let pressure: Int
    let description: String
    let conditionGroup: String
    let iconURL: URL?
    let windSpeed: Double
    let windDeg: Int
    let cloudiness: Int
    let cityName: String
    let country: String?

    init(from dto: WeatherResponseDTO) {
        temperature = dto.main.temp
        feelsLike = dto.main.feelsLike
        tempMin = dto.main.tempMin
        tempMax = dto.main.tempMax
        humidity = dto.main.humidity
        pressure = dto.main.pressure

        let condition = dto.weather.first
        description = condition?.description ?? ""
        conditionGroup = condition?.main ?? ""

        if let icon = condition?.icon {
            iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
        } else {
            iconURL = nil
        }

        windSpeed = dto.wind?.speed ?? 0
        windDeg = dto.wind?.deg ?? 0
        cloudiness = dto.clouds?.all ?? 0
        cityName = dto.name
        country = dto.sys?.country
    }
}
