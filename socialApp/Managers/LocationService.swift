//
//  LocationService.swift
//  socialApp
//
//  Created by Денис Щиголев on 06.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import MapKit

class LocationService: UIResponder {
    
    static let shared = LocationService()
    
    private var userID: String?
    private let locationManager = CLLocationManager()
    
    func getCoordinate(userID: String, complition:@escaping(Bool)->Void) {
        self.userID = userID
        locationManager.delegate = self
       
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.requestLocation()
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            //show alert and go to system settings to change geo settings for app
            complition(false)
         default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func checkLocationIsDenied() -> Bool{
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .denied:
            return true
         default:
            return false
        }
    }
}

//MARK: CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let coordinate = location.coordinate
            guard let userID = userID else { fatalError("Cant get userID for location")}
            FirestoreService.shared.saveLocation(userID: userID,
                                                 longitude: coordinate.longitude,
                                                 latitude: coordinate.latitude) {[weak self] result in
                switch result {
                
                case .success(let location):
                    self?.userID = nil
                    var people = UserDefaultsService.shared.getMpeople()
                    people?.location = location
                    UserDefaultsService.shared.saveMpeople(people: people)
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        
        case .authorizedAlways:
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.requestLocation()
        case .authorizedWhenInUse:
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.requestLocation()
         default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
        let authorizationStatus = CLLocationManager.authorizationStatus()
            if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
                locationManager.requestWhenInUseAuthorization()
            }
    }
}
