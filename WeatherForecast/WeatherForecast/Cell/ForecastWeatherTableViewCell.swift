//
//  ForecastWeatherTableViewCell.swift
//  WeatherForecast
//
//  Created by 김지혜 on 2021/01/19.
//

import UIKit

class ForecastWeatherTableViewCell: UITableViewCell {
    private var model: Weather?
    private var index: Int?
    
    @IBOutlet private weak var datetimeLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var weatherIconImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        datetimeLabel.text = nil
        temperatureLabel.text = nil
        weatherIconImageView.image = nil
    }
    
    func setModel(_ model: Weather, index: Int) {
        self.model = model
        self.index = index
        setUI()
    }
    
    private func setUI() {
        guard let weather = model,
              let mainWeather = weather.main.first,
              let index = index else { return }
        
        datetimeLabel.text = weather.dateTime.toFormattedStringDate()
        temperatureLabel.text = "\(weather.temperature.avg.celcius)°"
        
        WeatherManager.shared.getWeatherImage(id: mainWeather.iconId, index: index) { [weak self] image, index in
            guard index == self?.index else { return }
            self?.weatherIconImageView.image = image
        }
    }
}

extension Int {
    func toFormattedStringDate() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd(E) HH시"
        dateFormatter.timeZone = .autoupdatingCurrent
        dateFormatter.locale = .autoupdatingCurrent
        
        return dateFormatter.string(from: date)
    }
}
