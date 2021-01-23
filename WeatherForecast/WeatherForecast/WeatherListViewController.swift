//
//  WeatherForecast - WeatherListViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.

import UIKit

final class WeatherListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var weatherIconImageView: UIImageView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var temperaturesLabel: UILabel!
    @IBOutlet private weak var mainTemperatureLabel: UILabel!
    
    private var fivedaysForecastWeathers: [Weather] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .white
        control.addTarget(self, action: #selector(refreshUI), for: .valueChanged)
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        NotificationCenter.default.addObserver(self, selector: #selector(setUp), name: Notification.Name.locationUpdate, object: nil)
        LocationManager.shared.updateLocation()
    }
    
    @objc private func refreshUI() {
        LocationManager.shared.updateLocation()
        setUp()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
}

extension WeatherListViewController {
    @objc private func setUp() {
        guard let coordinate = LocationManager.shared.locationCoordinate else { return }
        LocationManager.shared.getLocalizationString(in: "Ko-kr") { (locationString) in
            DispatchQueue.main.async {
                self.addressLabel.text = locationString
            }
        }
        WeatherManager.shared.getCurrentWeather(of: coordinate) { [weak self] (weather) in
            DispatchQueue.main.async {
                self?.setCurrentWeather(weather)
            }
        }
        
        WeatherManager.shared.getFivedaysForecastWeathers(of: coordinate) {
            self.fivedaysForecastWeathers = $0
        }
    }
    
    private func setCurrentWeather(_ weather: Weather) {
        guard let mainWeather = weather.main.first else { return }
        
        temperaturesLabel.text = "최저 \(weather.temperature.min.celcius)° 최고 \(weather.temperature.max.celcius)°"
        mainTemperatureLabel.text = "\(weather.temperature.avg.celcius)°"
        
        WeatherManager.shared.getWeatherImage(id: mainWeather.iconId) { [weak self] image, _ in
            self?.weatherIconImageView.image = image
        }
    }
}

extension WeatherListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fivedaysForecastWeathers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastWeatherTableViewCell", for: indexPath) as? ForecastWeatherTableViewCell else { return .init() }
        
        cell.setModel(fivedaysForecastWeathers[indexPath.row], index: indexPath.row)
        
        return cell
    }
}

extension Double {
    var celcius: Double {
        let celcius: Double = self - 273.15
        
        return floor(celcius * 10) / 10
    }
}
