//
//  CurrentLocationManager.swift
//  Scavenger Hunt Platform
//
//  Created by Umar Patel on 4/26/24.
//

import Foundation
import SwiftUI
import SwiftData
import MapKit
import CoreLocation

let CentralStanfordCampus = (37.42749137163412, -122.17028175677483)

let CentralStanfordSpan = (0.01, 0.01)


final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    public var city: String
    public var mapRegionLatitude: CLLocationDegrees
    public var mapRegionLongitude: CLLocationDegrees
    
    @Published var mapRegion: MapCameraPosition
    @Published var currentLocation: CLLocationCoordinate2D?
    
    // This is to store pin drops for the different hunts
    @Published var huntLocations: [CLLocationCoordinate2D] = []
    
    init(cityName: String, regionLatitude: CLLocationDegrees, regionLongitude: CLLocationDegrees) {
        self.city = cityName
        self.mapRegionLatitude = regionLatitude
        self.mapRegionLongitude = regionLongitude
        
        self.mapRegion = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.mapRegionLatitude, longitude: self.mapRegionLongitude), span: MKCoordinateSpan(latitudeDelta: CentralStanfordSpan.0, longitudeDelta: CentralStanfordSpan.1)))
        
        super.init()
        
        self.locationManager.delegate = self        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.setup()
    }
    
    func setup() {
        switch locationManager.authorizationStatus {
        // If we are authorized then we request location just once, to center the map
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        // If we don't, we request authorization
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func addHuntLocation(_ coordinate: CLLocationCoordinate2D) {
        huntLocations.append(coordinate)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // locationManager.stopUpdatingLocation()
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
    }
}

/*
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // locationManager.stopUpdatingLocation()
        if let location = locations.last {
            
            let newRegion = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: CentralStanfordSpan.0, longitudeDelta: CentralStanfordSpan.1)
            )
            self.mapRegion = MapCameraPosition.region(newRegion)
            
            self.currentLocation = location.coordinate
        }
    }
    
}
*/

