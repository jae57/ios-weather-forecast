//
//  WeatherManager.swift
//  WeatherForecast
//
//  Created by 김지혜 on 2021/01/19.
//

import Foundation

struct WeatherManager {
    private enum ServiceApi {
        case currentWeather(Double, Double)
        case fiveDaysForecastWeathers(Double, Double)
        case weatherIconImage(String)
        
        var apiKey: String {
            switch self {
            case .currentWeather, .fiveDaysForecastWeathers, .weatherIconImage:
                return "1c3be24879e17dcc0bd319a5d7afe693"
            }
        }
        
        var urlString: String {
            switch self {
            case .currentWeather:
                return "https://api.openweathermap.org/data/2.5/weather"
            case .fiveDaysForecastWeathers:
                return "https://api.openweathermap.org/data/2.5/forecast"
            case .weatherIconImage:
                return "https://openweathermap.org/img/w"
            }
        }
        
        var query: String {
            switch self {
            case let .currentWeather(latitude, longitude),
                 let .fiveDaysForecastWeathers(latitude, longitude):
                return "lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
            case let .weatherIconImage(id):
                return "\(id).png"
            }
        }
        
        var fullUrl: URL? {
            switch self {
            case .currentWeather, .fiveDaysForecastWeathers:
                var urlComponents = URLComponents(string: urlString)
                urlComponents?.query = query
                return urlComponents?.url
            case .weatherIconImage:
                return URL(string: urlString)?.appendingPathComponent(query)
            }
        }
    }
    
    static let shared = WeatherManager()
    private init() {}
    
    func getCurrentWeather(of coordinate: Coordinate, completion: @escaping (Weather) -> Void) {
        guard let url = ServiceApi.currentWeather(coordinate.latitude, coordinate.longitude).fullUrl else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response: Weather = try JSONDecoder().decode(Weather.self, from: data)
                    completion(response)
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
    
    func getFivedaysForecastWeathers(of coordinate: Coordinate, completion: @escaping ([Weather]) -> Void) {
        guard let url = ServiceApi.fiveDaysForecastWeathers(coordinate.latitude, coordinate.longitude).fullUrl else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response: FivedaysForecastWeathers = try JSONDecoder().decode(FivedaysForecastWeathers.self, from: data)
                    completion(response.weathers)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    func getWeatherImage(id: String, completion: @escaping (Data) -> Void) {
        guard let url = ServiceApi.weatherIconImage(id).fullUrl else { return }
        
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            completion(data)
        }
    }
}
