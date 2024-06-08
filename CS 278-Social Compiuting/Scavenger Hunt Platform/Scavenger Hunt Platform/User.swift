//
//  User.swift
//  Scavenger Hunt Platform
//
//  Created by Umar Patel on 5/23/24.
//

import Foundation
import SwiftUI
import SwiftData
import MapKit

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var username: String
    var password: String
    // User hunt structure: [Name of hunt, Whether they are finished with the hunt]
    var userHunts: [String:Bool]     // this would just be the title of the hunt, and then you can use the SwiftData fetch descriptor to fetch it. Basically, these are all the hunts that the user is a part of.
    // Indicating how many total points the user has (based on how many hunts they complete)
    var totalPoints: Int    // This will be used for leaderboard purposes.
    var placedMarkerForHunts: [String:Bool]  // This will be different for each user, depending on whether they have a marker placed for the respective hunt
    
    init(id: UUID, username: String, password: String) {
        self.id = UUID()
        self.username = username
        self.password = password
        self.userHunts = [:]     // Initially, you can just initialize this to an empty list. And then append as the user joins more and more hunts
        self.totalPoints = 0
        self.placedMarkerForHunts = [:]
    }
    
    func addHunt(hunt: ScavengerHunt) {
        // Add hunt to the dictionary
        print("Hunt is added")
        self.userHunts[hunt.huntTitle] = false
        // Add marker status to dictionary
        self.placedMarkerForHunts[hunt.huntTitle] = false
    }
    
    func addScore(points: Int) {
        self.totalPoints += points
    }
    
    func updateHuntStatus(hunt: String) {
        self.userHunts[hunt] = true
    }
    
    
    
}

