//
//  WeatherManager.swift
//  WeatherForecast
//
//  Created by 김지혜 on 2021/01/19.
//

import Foundation

protocol WeatherManagerDelegate: AnyObject {
    func setCurrentWeather(_ response: Weather)
    func setFiveDaysForecastWeathers(_ response: FivedaysForecastWeathers)
}

final class WeatherManager {
    private enum ApiUrls {
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
    
    weak var delegate: WeatherManagerDelegate?
    
    // TODO: 두 api 공통부분 뽑아내기 resume 하는 부분이나 error 처리 같은 부분
    // Coordinate 던지기
    func getCurrentWeather(latitude: Double, longitude: Double) {
        // TODO: 이름 약간 변경필요 ApiUrls -> ApiserviceX
        guard let url = ApiUrls.currentWeather(latitude, longitude).fullUrl else { return }
        // get, post 명시적으로 변경
        print(url)
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
        guard let url = ApiUrls.fiveDaysForecastWeathers(latitude, longitude).fullUrl else { return }
        print(url)
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // response 처리해주거나 안쓸거면 _ 처리 하기
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
        return ApiUrls.weatherIconImage(id).fullUrl
    }
}
