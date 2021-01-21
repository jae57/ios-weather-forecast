//
//  WeatherModel.swift
//  WeatherForecast
//
//  Created by 김지혜 on 2021/01/18.
//

import Foundation

struct FivedaysForecastWeathers: Decodable {
    var code: String
    var message: Double
    var count: Int
    var weathers: [Weather]
    
    enum CodingKeys: String, CodingKey {
        case code = "cod"
        case message
        case count = "cnt"
        case weathers = "list"
    }
}

struct Weather: Decodable {
    var dateTime: Int
    var temperature: Temperature
    var main: [MainWeather]
    
    enum CodingKeys: String, CodingKey {
        case dateTime = "dt"
        case temperature = "main"
        case main = "weather"
    }
}

struct Temperature: Decodable {
    var avg: Double
    var min: Double
    var max: Double
    
    enum CodingKeys: String, CodingKey {
        case avg = "temp"
        case min = "temp_min"
        case max = "temp_max"
    }
}

struct MainWeather: Decodable {
    var iconId: String
    var group: String
    var condition: String
    
    enum CodingKeys: String, CodingKey {
        case iconId = "icon"
        case group = "main"
        case condition = "description"
    }
}
