//
//  HuntMarker.swift
//  Scavenger Hunt Platform
//
//  Created by Umar Patel on 5/15/24.
//

import Foundation
import SwiftUI
import MapKit

struct HuntMarker: Identifiable {
    let id: UUID
    var name: String
    var coordinates: CLLocationCoordinate2D
    
    init(name: String, coordinates: CLLocationCoordinate2D) {
        self.id = UUID()
        self.name = name
        self.coordinates = coordinates
    }
}
