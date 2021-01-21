//
//  WeatherForecast - WeatherListViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.

import UIKit
import CoreLocation

// 여기서만 쓸꺼니까 일단 여기에 구현
//extension {
//    func currerntApi(self ) {
//        weatherApiManager()
//    }
//}

final class WeatherListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private let weatherManager: WeatherManager = WeatherManager()
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private var currentWeather: Weather? {
        didSet {
//            DispatchQueue.main.async { [weak self] in
//                self?.tableView.reloadData()
//            }
            print("set currentWeather")
            isReady += 1
        }
    }
    private var fivedaysForecastWeathers: [Weather] = [] {
        didSet {
//            DispatchQueue.main.async { [weak self] in
//                self?.tableView.reloadData()
//            }
            print("set fivedaysForecastWeathers")
            isReady += 1
        }
    }
    private var currentLocation: Coordinate?
    private var currentAddress: CLPlacemark? {
        didSet {
            print("set currentAddress")
            isReady += 1
//            DispatchQueue.main.async { [weak self] in
//                self?.tableView.reloadData()
//            }
        }
    }
    // 변수명 수정 .. api call 다한 후 한번만 UI 업데이트 하는 부분
    private var isReady: Int = 0 {
        didSet {
            if isReady == 3 {
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
    }
    // location 여러번 업데이트 안하게 하는 flag
    private var hasLocation: Bool = false
    
    // TODO - initial 분리
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
        // 여기 좀 정리
        guard let location = currentLocation else { return }
        isReady = 0
        // current location 가져오도록
        if let cllocation = locationManager.location {
            getLocationLocaleString(location: cllocation)
        }
        weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
        weatherManager.getFivedaysForecastWeathers(latitude: location.latitude, longitude: location.longitude)
        tableView.reloadData()
        refreshControl.endRefreshing()
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
        guard hasLocation == false else { return }
        
        // flag 를 넣어서 한번만 새로고칠 수 있도록 하고, 끌어당겨서 새로고침 하는 부분에서 이 역할을 해주기(.refreshCell에서 호출?)
        let lastLocation: CLLocation = locations[locations.count - 1]
        getLocationLocaleString(location: lastLocation)
//        let geoCoder: CLGeocoder = CLGeocoder()
//        let local: Locale = Locale(identifier: "Ko-kr")
//
//        geoCoder.reverseGeocodeLocation(lastLocation, preferredLocale: local) { (place, error) in
//            if let address: [CLPlacemark] = place,
//               let lastAddress: CLPlacemark = address.last {
//                self.currentAddress = lastAddress
//            }
//        }
        hasLocation = true
    }
    
    private func getLocationLocaleString(location: CLLocation) {
        let geoCoder: CLGeocoder = CLGeocoder()
        let local: Locale = Locale(identifier: "Ko-kr")
        
        geoCoder.reverseGeocodeLocation(location, preferredLocale: local) { (place, error) in
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentWeatherTableViewCell", for: indexPath) as? CurrentWeatherTableViewCell else { return .init() }
            
            cell.model = currentWeather
            cell.addressModel = currentAddress
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastWeatherTableViewCell", for: indexPath) as? ForecastWeatherTableViewCell else { return .init() }
            
            cell.model = fivedaysForecastWeathers[indexPath.row - 1]
            
            return cell
        }
    }
    
    // image 에다가 줘
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 120
        } else {
            return 50
        }
    }
}

extension Double {
    var celcius: Double {
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

// TDD 만들기
