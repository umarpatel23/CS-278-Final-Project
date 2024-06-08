//
//  ScavengerHuntView.swift
//  Scavenger Hunt Platform
//
//  Created by Umar Patel on 4/27/24.
//

import SwiftUI
import SwiftData
import MapKit
import CoreLocation

struct ScavengerHuntView: View {
    @Binding var currentUser: User
    @Binding var userGuessLatitude: CLLocationDegrees
    @Binding var userGuessLongitude: CLLocationDegrees
    @Binding var placedGuessMarkers: [String:Bool]
    @Binding var currentHunt: String
    
    // Might have to change all of these to lets
    let datePosted: Date
    let huntName: String
    let huntDescription: String
    // Just show all the hints; use sendback data to update the current level for the user struct
    let levelHints: [Int:String]
    let levelVerificationCodes: [Int:Int]
    let numPeopleCompleted: Int
    let huntLatitude: CLLocationDegrees
    let huntLongitude: CLLocationDegrees
    
    let numLevels: Int
    // Variable to store the user's code entry
    @State var usersCurrentLevelCodeEntries: [Int: String] = [:]
    
    // Variable to store the text of whether or not the user won the hunt
    @State var huntStatusText: String = ""
    
    var body: some View {
        // Maybe put a map here and the location of the place
        
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Date Posted: \(datePosted)")
                        .padding(20)
                    
                    Text("Number of people completed: \(numPeopleCompleted)")
                    
                    Text("Description: \(huntDescription)")
                        .padding(20)
                    
                    // Display the hints for each level here
                    Text("Hints")
                        .padding(20)
                    ForEach(1 ... numLevels, id: \.self) { level in
                        if let hint = levelHints[level], !hint.isEmpty {
                            Text("Hint \(level): \(hint)")
                                .padding()
                        }
                    }
                    
                    Text("When you feel you have found the right location, tap the map where you think the place is and press the button below!")
                        .padding(20)
                    
                    Button("Check your guess") {
                        // Check if current location is close enough to the
                        // latitude and longitude coordinates of
                        if (placedGuessMarkers[huntName] == true) && (currentUser.userHunts[huntName] == false) {
                            let isGuessCorrect = isWithinDistance(lat1: userGuessLatitude, lon1: userGuessLongitude, lat2: huntLatitude, lon2: huntLongitude)
                            if isGuessCorrect {
                                huntStatusText = "You've Guessed Correctly. You won the Hunt!"
                                currentUser.updateHuntStatus(hunt: huntName)
                                currentUser.addScore(points: 10)
                            }
                            else {
                                huntStatusText = "Nice try! But that's not quite the place!"
                            }
                        }
                        
                    }
                    .padding(20)
                    
                    Text(currentHunt)
                    
                    // Add a Navigation Link to the thread view
                    NavigationLink(destination: ThreadView(username: currentUser.username, huntName: huntName)) {
                        Text("Go to discussion forum")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(20)
                    
                    Text(huntStatusText)
                        .font(.system(size: 24))
                        .padding(20)
                
                    
                    /*
                    Button("test button") {
                        print(currentHunt)
                        print(String(placedGuessMarkers[currentHunt]!))
                    }
                    */
                    
                    // Display the hints for each level here
                    
                    
                    
                    // Display the Input TextFields for each verification code here
                    
                    /*
                    Text("Input your verification codes here:")
                        .padding(20)
                    
                    ForEach(1...numLevels, id: \.self) { level in
                        if levelVerificationCodes[level] != 0 {
                            TextField("Enter Code for Level \(level)", text: Binding(
                                get: { usersCurrentLevelCodeEntries[level, default: ""] },
                                set: { usersCurrentLevelCodeEntries[level] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .keyboardType(.numberPad)
                        }
                    }
                     */
                    
                    // Display the Input TextFields for each verification code here
                    
                    
                    
                }
                
            }
            
        }
        .navigationTitle(huntName)
        .onAppear() {
            if currentUser.userHunts[huntName] == true {
                huntStatusText = "You've Guessed Correctly. You won the Hunt!"
            }
            currentHunt = huntName
        }
        .onDisappear() {
            currentHunt = ""
        }
    }
    
    
    func isWithinDistance(lat1: CLLocationDegrees, lon1: CLLocationDegrees, lat2: CLLocationDegrees, lon2: CLLocationDegrees) -> Bool {
        let location1 = CLLocation(latitude: lat1, longitude: lon1)
        let location2 = CLLocation(latitude: lat2, longitude: lon2)
        let distance = location1.distance(from: location2)  // distance in meters

        return distance <= 150
    }
    
}

/*
#Preview {
    ScavengerHuntView()
}
*/
