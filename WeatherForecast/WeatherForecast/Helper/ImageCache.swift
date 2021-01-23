//
//  ImageCache.swift
//  WeatherForecast
//
//  Created by 김지혜 on 2021/01/23.
//

import UIKit

final class ImageCache {
    static let shared: ImageCache = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private init() {}
    
    subscript(_ url: URL?) -> UIImage? {
        get {
            guard let url = url else { return nil }
            let key = NSString(string: url.absoluteString)
            
            return cache.object(forKey: key)
        }
        set {
            guard let url = url,
                  let image = newValue else { return }
            let key = NSString(string: url.absoluteString)
            
            cache.setObject(image, forKey: key)
        }
    }
}
