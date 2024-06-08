//
//  HuntLocationManager.swift
//  Scavenger Hunt Platform
//
//  Created by Umar Patel on 5/14/24.
//

import Foundation
import SwiftUI
import MapKit

class HuntLocationManager: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var locations: [CLLocationCoordinate2D] = []
    
    init() {
        // Set default location
        self.region = MKCoordinateRegion(center: )
    }
    
}
