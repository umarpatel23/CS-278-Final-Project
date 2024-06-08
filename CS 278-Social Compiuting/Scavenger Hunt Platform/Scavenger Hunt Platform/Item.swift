//
//  Item.swift
//  Scavenger Hunt Platform
//
//  Created by Umar Patel on 4/25/24.
//

import Foundation
import SwiftData
import MapKit

@Model
final class ScavengerHunt {
    @Attribute(.unique) var id: UUID
    var datePosted: Date
    var huntTitle: String
    var huntDescription: String
    var levelsHints: [Int:String]    // The hints, created by the creator of the scavenger hunt, for each level; this can be changed to [Int:[String]] if you want to have multiple-creator created hints per level
    var levelVerificationCodes: [Int:Int]
    // have to have some variable that shows progress
    var numPeopleCompleted: Int // number of people who completed the Scavenger Hunt
    // For placing the pin
    var huntLatitude: CLLocationDegrees
    var huntLongitude: CLLocationDegrees
    
    var numLevels: Int
    
    // Mode code below
    
    init(timestamp: Date, huntTitle: String, huntDescription: String, levelHints: [Int:String], levelVerificationCodes: [Int:Int], huntLatitude: CLLocationDegrees, huntLongitude: CLLocationDegrees) {
        self.id = UUID() // May need to change this or add another one if you want to get an associated chat for this scavenger hunt
        self.datePosted = timestamp
        self.huntTitle = huntTitle
        self.huntDescription = huntDescription
        self.levelsHints = levelHints
        self.levelVerificationCodes = levelVerificationCodes
        self.numPeopleCompleted = 0 // There will be a function to increment this as people complete it
        self.huntLatitude = huntLatitude
        self.huntLongitude = huntLongitude
        
        // Number of levels is dependent on the number of non-empty strings in levelHints
        self.numLevels = levelHints.keys.sorted().reduce(0) { (result, key) in
                guard let hint = levelHints[key], !hint.isEmpty else { return result }
                return result + 1
            
        }
        
        
    }
    
    func addHint(level: Int, hint: String) {
        self.levelsHints[level] = hint
    }
    
    func incrementNumCompleted() {
        self.numPeopleCompleted += 1
    }
    
    func getHuntTitle() -> String {
        return self.huntTitle
    }
    
    func getHuntLatitude() -> CLLocationDegrees {
        return self.huntLatitude
    }
    
    func getHuntLongitude() -> CLLocationDegrees {
        return self.huntLongitude
    }
    
    
}
