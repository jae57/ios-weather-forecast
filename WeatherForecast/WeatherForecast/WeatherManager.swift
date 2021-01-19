//
//  WeatherManager.swift
//  WeatherForecast
//
//  Created by 김지혜 on 2021/01/19.
//

import Foundation

protocol WeatherManagerDelegate: class {
    func setCurrentWeather(_ response: Weather)
    func setFiveDaysForecastWeathers(_ response: FivedaysForecastWeathers)
}

enum WeatherApi {
    case currentWeather
    case fiveDaysForecastWeathers
    case weatherIconImage
    
    var url: String {
        switch self {
        case .currentWeather:
            return "https://api.openweathermap.org/data/2.5/weather"
        case .fiveDaysForecastWeathers:
            return "https://api.openweathermap.org/data/2.5/forecast"
        case .weatherIconImage:
            return "https://openweathermap.org/img/w"
        }
    }
}

final class WeatherManager {
//    static let shared: WeatherManager = WeatherManager()
    
    private let apiKey: String  = "1c3be24879e17dcc0bd319a5d7afe693"
    weak var delegate: WeatherManagerDelegate?
    
//    private init() {}
    
    // TODO: 두 api 공통부분 뽑아내기 resume 하는 부분이나 error 처리 같은 부분
    func getCurrentWeather(latitude: Double, longitude: Double) {
        guard var urlComponents = URLComponents(string: WeatherApi.currentWeather.url) else { return }
        urlComponents.query = "lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        guard let url = urlComponents.url else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data {
                do {
                    let response: Weather = try JSONDecoder().decode(Weather.self, from: data)
                    self?.delegate?.setCurrentWeather(response)
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
    
    func getFivedaysForecastWeathers(latitude: Double, longitude: Double) {
        guard var urlComponents = URLComponents(string: WeatherApi.fiveDaysForecastWeathers.url) else { return }
        urlComponents.query = "lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        guard let url = urlComponents.url else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data {
                do {
                    let response: FivedaysForecastWeathers = try JSONDecoder().decode(FivedaysForecastWeathers.self, from: data)
                    self?.delegate?.setFiveDaysForecastWeathers(response)
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
    
    func getWeatherIconImageUrl(id: String) -> URL? {
        guard let url = URL(string: WeatherApi.weatherIconImage.url) else { return nil }
        
        return url.appendingPathComponent("\(id).png")
    }
    
    func toCelcius(temperature: Double) -> Double {
        return ( temperature - 32 ) * 5 / 9
    }
}
