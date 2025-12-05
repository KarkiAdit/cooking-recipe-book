//
//  LocationManager.swift
//  CookBook
//
//  Created by Aditya Karki on 12/5/25.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var locationDescription: String = ""
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocationIfNeeded() {
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        
        DispatchQueue.main.async {
            self.location = loc
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(loc) { placemarks, _ in
            guard let place = placemarks?.first else { return }
            
            let city = place.locality ?? place.subAdministrativeArea
            let region = place.administrativeArea
            let country = place.country
            
            let parts = [city, region, country].compactMap { $0 }.joined(separator: ", ")
            
            DispatchQueue.main.async {
                self.locationDescription = parts.isEmpty ? "Unknown" : parts
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationDescription = "Unknown"
        }
    }
}
