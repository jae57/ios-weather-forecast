//
//  ForecastWeatherTableViewCell.swift
//  WeatherForecast
//
//  Created by 김지혜 on 2021/01/19.
//

import UIKit

class ForecastWeatherTableViewCell: UITableViewCell {
    var model: Weather? {
        didSet {
            setValues()
        }
    }
    
    @IBOutlet private weak var datetimeLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var weatherIconImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        datetimeLabel.text = nil
        temperatureLabel.text = nil
        weatherIconImage.image = nil
    }
    
    private func setValues() {
        guard let mainWeather = weather.main.first,
              let iconUrl = weatherManager.getWeatherIconImageUrl(id: mainWeather.iconId) else {
            return .init()
        }
        
        cell.datetimeLabel.text = weather.dateTime.toFormattedStringDate()
        cell.temperatureLabel.text = "\(weather.temperature.avg.toCelcius())°"
        cell.weatherIconImage.load(url: iconUrl)
        //weather.temperature.avg.celcius
    }
}
