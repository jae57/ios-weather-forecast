//
//  LocationManager.swift
//  WeatherForecast
//
//  Created by 김지혜 on 2021/01/22.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject {
    static let shared = LocationManager()
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        return manager
    }()
    private var location: CLLocation? {
        didSet {
            NotificationCenter.default.post(name: .locationUpdate, object: nil)
        }
    }
    var locationCoordinate: Coordinate? {
        get {
            guard let location = location else { return nil }
            
            return Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    private override init() {
        super.init()
        locationManager.delegate = self
        updateLocation()
    }
    
    func updateLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func getLocalizationString(in locale: String, completion: @escaping (String) -> Void) {
        guard let location = location else { return }
        
        let geoCoder: CLGeocoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: locale)) { (place, error) in
            if let address: [CLPlacemark] = place,
               let lastAddress: CLPlacemark = address.last,
               let area = lastAddress.administrativeArea,
               let locality = lastAddress.locality {
                completion("\(area) \(locality)")
            } else {
                print("위치정보를 localize하는데 실패했습니다")
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        locationManager.stopUpdatingLocation()
    }
}

extension Notification.Name {
    static let locationUpdate: Notification.Name = Notification.Name(rawValue: "locationUpdate")
}
