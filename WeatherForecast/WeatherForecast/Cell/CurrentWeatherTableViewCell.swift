//
//  CurrentWeatherTableViewCell.swift
//  WeatherForecast
//
//  Created by 김지혜 on 2021/01/19.
//

import UIKit

class CurrentWeatherTableViewCell: UITableViewCell {
    // private 바꾸기
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var temperaturesLabel: UILabel!
    @IBOutlet weak var mainTemperatureLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        weatherIconImageView.image = nil
        addressLabel.text = nil
        temperaturesLabel.text = nil
        mainTemperatureLabel.text = nil
    }
}
