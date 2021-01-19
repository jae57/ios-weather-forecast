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
    var weatherIcon: [WeatherIcon]
    
    enum CodingKeys: String, CodingKey {
        case dateTime = "dt"
        case temperature = "main"
        case weatherIcon = "weather"
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

struct WeatherIcon: Decodable {
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "icon"
    }
}


