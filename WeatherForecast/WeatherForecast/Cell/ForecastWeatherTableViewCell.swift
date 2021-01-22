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
    @IBOutlet private weak var weatherIconImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        datetimeLabel.text = nil
        temperatureLabel.text = nil
        weatherIconImageView.image = nil
    }
    
    private func setValues() {
        guard let weather = model,
              let mainWeather = weather.main.first else { return }
        
        datetimeLabel.text = weather.dateTime.toFormattedStringDate()
        temperatureLabel.text = "\(weather.temperature.avg.celcius)°"
        
        WeatherManager.shared.getWeatherImage(id: mainWeather.iconId) {
            guard let image = UIImage(data: $0) else { return }
            
            DispatchQueue.main.async {
                self.weatherIconImageView.image = image
            }
        }
    }
}

extension Int {
    func toFormattedStringDate() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd(E) HH시"
        dateFormatter.locale = Locale(identifier: "ko")
        
        return dateFormatter.string(from: date)
    }
}
