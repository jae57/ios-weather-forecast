//
//  ForecastWeatherTableViewCell.swift
//  WeatherForecast
//
//  Created by 김지혜 on 2021/01/19.
//

import UIKit

class ForecastWeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIconImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        datetimeLabel.text = nil
        temperatureLabel.text = nil
        weatherIconImage.image = nil
    }
}
