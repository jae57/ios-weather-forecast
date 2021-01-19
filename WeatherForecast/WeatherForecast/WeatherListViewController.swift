//
//  WeatherForecast - WeatherListViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.

import UIKit
import CoreLocation

struct Coordinate {
    var latitude: Double
    var longitude: Double
}

final class WeatherListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private let weatherManager: WeatherManager = WeatherManager()
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private var currentWeather: Weather? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    private var fivedaysForecastWeathers: [Weather] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    private var currentLocation: Coordinate?
    private var currentAddress: CLPlacemark? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherManager.delegate = self
        
        // 이런 부수적인 세팅들을 변수로 몰아버릴 수 있는지?
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        getCurrentLocation()
        
        guard let location = currentLocation else { return }
        // coordinate 로 type 하나 만들어서 extension 으로 weather 가져오게 해도 될 듯 ?
        weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
        weatherManager.getFivedaysForecastWeathers(latitude: location.latitude, longitude: location.longitude)
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshCells), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc
    private func refreshCells() {
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    private func getCurrentLocation() {
        guard let location = locationManager.location else { return }
        currentLocation = Coordinate(latitude: location.coordinate.latitude,
                                     longitude: location.coordinate.longitude)
    }
}

extension WeatherListViewController: WeatherManagerDelegate {
    func setCurrentWeather(_ response: Weather) {
        currentWeather = response
    }
    
    func setFiveDaysForecastWeathers(_ response: FivedaysForecastWeathers) {
        fivedaysForecastWeathers = response.weathers
    }
}

extension WeatherListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation: CLLocation = locations[locations.count - 1]
        let geoCoder: CLGeocoder = CLGeocoder()
        let local: Locale = Locale(identifier: "Ko-kr")
        
        geoCoder.reverseGeocodeLocation(lastLocation, preferredLocale: local) { (place, error) in
            if let address: [CLPlacemark] = place,
               let lastAddress: CLPlacemark = address.last {
                self.currentAddress = lastAddress
            }
        }
    }
}

extension WeatherListViewController: UITableViewDelegate {
}

extension WeatherListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = currentWeather else { return fivedaysForecastWeathers.count }
        
        return fivedaysForecastWeathers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentWeatherTableViewCell", for: indexPath) as? CurrentWeatherTableViewCell,
                  let weather = currentWeather,
                  let weatherIcon = weather.weatherIcon.first,
                  let iconUrl = weatherManager.getWeatherIconImageUrl(id: weatherIcon.id),
                  let address = currentAddress,
                  let area = address.administrativeArea,
                  let locality = address.locality else { return .init() }
            
            cell.weatherIconImageView.load(url: iconUrl)
            cell.addressLabel.text = "\(area) \(locality)"
            cell.temperaturesLabel.text = "최저 \(weather.temperature.min.toCelcius())° 최고 \(weather.temperature.max.toCelcius())°"
            cell.mainTemperatureLabel.text = "\(weather.temperature.avg.toCelcius())°"
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastWeatherTableViewCell", for: indexPath) as? ForecastWeatherTableViewCell else { return .init() }
            let weather = fivedaysForecastWeathers[indexPath.row - 1]
            guard let weatherIcon = weather.weatherIcon.first,
                  let iconUrl = weatherManager.getWeatherIconImageUrl(id: weatherIcon.id) else {
                return .init()
            }
            
            cell.datetimeLabel.text = weather.dateTime.toFormattedStringDate()
            cell.temperatureLabel.text = "\(weather.temperature.avg.toCelcius())°"
            cell.weatherIconImage.load(url: iconUrl)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 120
        } else {
            return 50
        }
    }
}

extension Double {
    func toCelcius() -> Double {
        let celcius: Double = self - 273.15
        
        return floor(celcius * 10) / 10
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

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
}
