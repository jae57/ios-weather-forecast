//
//  CurrentWeatherTableViewCell.swift
//  WeatherForecast
//
//  Created by 김지혜 on 2021/01/19.
//

import UIKit
import CoreLocation // 지울 수 있도록 address 어떻게 해보기

class CurrentWeatherTableViewCell: UITableViewCell {
    var model: Weather? {
        didSet {
            setValues()
        }
    }
    // address 꼭 이렇게 따로 받아와야 하는지 한번 고려해볼것
    var addressModel: CLPlacemark? {
        didSet {
            setAddress()
        }
    }
    
    @IBOutlet private weak var weatherIconImageView: UIImageView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var temperaturesLabel: UILabel!
    @IBOutlet private weak var mainTemperatureLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        weatherIconImageView.image = nil
        addressLabel.text = nil
        temperaturesLabel.text = nil
        mainTemperatureLabel.text = nil
    }
    
    private func setValues() {
        // guard let 이 너무 김 -> 해결방법? -. 옵셔널 처리도 cell 에서 하자. computed property?
        // get, set 으로 스트링 변환 같은거 하라는 얘기인듯?
        guard let weather: Weather = model,
              let address: CLPlacemark = addressModel else { return }
        
        let mainWeather = weather.main.first
        // weatherManager.shared..?
        //let iconUrl = weatherManager.getWeatherIconImageUrl(id: mainWeather.iconId)
        let area = address.administrativeArea
        let locality = address.locality
        
        //weatherIconImageView.load(url: iconUrl)
        addressLabel.text = "\(area) \(locality)"
        temperaturesLabel.text = "최저 \(weather.temperature.min.celcius)° 최고 \(weather.temperature.max.celcius)°"
        mainTemperatureLabel.text = "\(weather.temperature.avg.celcius)°"
    }
    
    private func setAddress() {
        
    }
}
