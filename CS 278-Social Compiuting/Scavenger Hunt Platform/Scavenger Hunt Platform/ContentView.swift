//
//  ContentView.swift
//  Scavenger Hunt Platform
//
//  Created by Umar Patel on 4/25/24.
//

import SwiftUI
import SwiftData
import MapKit
import CoreLocation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var hunts: [ScavengerHunt]
    @Query private var users: [User]
    
    // Create an empty object that will be populated with
    // the data from when creating a new scavenger hunt
    // object.
    @State var listOfData: (String, String, [Int:String], [Int:Int]) = ("", "", [:], [:])
    
    // Map of Stanford
    // Stanford coordinates: 37.42744826078055, -122.17025380024745
    // @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.42744826078055, longitude: -122.17025380024745), span: MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001)))
    
    // To switch between the main view and the create hunt view
    @State var showCreateHuntView: Bool = false

    // Create hunt view variables
    // Create state variables to hold the input texts
    @State var huntTitle: String = ""
    @State var huntDescription: String = ""
    @State var levelHints: [Int:String] = Dictionary(uniqueKeysWithValues: (1...10).map {($0, "")})
    @State var levelVerificationCodes: [Int:String] = Dictionary(uniqueKeysWithValues: (1...10).map {($0, "")})
    
    // For dropping a pin on the CreateHuntView and getting the coordinates
    @State var latitudeText: String = ""
    @State var longitudeText: String = ""
    
    // For the user's guess for the current hunt
    @State var guessLatitudeCoordinate: CLLocationDegrees = CLLocationDegrees()
    @State var guessLongitudeCoordinate: CLLocationDegrees = CLLocationDegrees()

    @State private var markerCoordinate: CLLocationCoordinate2D?    // This is for when you are placing the location of the hunt on the map when creating the scavenger hunt
    @State private var placedMarker: Bool = false // This is for when you are creating a hunt and dropping a pin at its location
    
    @State private var placedGuessMarkers: [String: Bool] = [:] // This is for your guess for the current hunt
    
    @State private var currentHuntInView: String = "" // This is for the current hunt the user is viewing and guessing for
        
    @State private var isListHintsExpanded: Bool = false
    @State private var isListCodesExpanded: Bool = false
    
    // For current location
    @StateObject var manager: LocationManager = LocationManager(cityName: "Stanford", regionLatitude: CentralStanfordCampus.0, regionLongitude: CentralStanfordCampus.1)
        
    // For NavigationLink
    @State private var selectedHunt: ScavengerHunt?
    
    // For setting up username/password and login stuff
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var loginText: String = ""
    @State private var loggedIn: Bool = false
    
    // For registering a new account (username and password)
    @State private var isRegistering: Bool = false
    @State private var registerUsername: String = ""
    @State private var registerPassword1: String = ""
    @State private var registerPassword2: String = ""
    @State private var registerText: String = ""
    
    
    // This empty user is just for the start of the experience but is technically not a valid user.
    @State private var currentUser: User = User(id: UUID(), username: "", password: "")
    
    // This is a variable to store the list of hunts associated with the current user. It's set once the user logs in.
    @State private var currentUserHunts: [ScavengerHunt] = []
        
    var body: some View {
        if isRegistering {
            VStack {
                Text(registerText)
                    .padding()
                    .frame(width: 400)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.red)
                
                Text("Please enter a username and password for your account!")
                    .padding()
                    .frame(width: 400)
                    .multilineTextAlignment(.center)
                
                TextField("Username", text: $registerUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $registerPassword1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Confirm Password", text: $registerPassword2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Register") {
                    // First ensure username is not taken
                    // Set up predicate and fetch
                    // this predicate checks to see whether any usernames match the one that the current user entered
                    let registerPredicate = #Predicate<User> {
                        $0.username == registerUsername
                    }
                    
                    let registerDescriptor = FetchDescriptor<User>(predicate: registerPredicate)
                    
                    do {
                        let anyMatches = try modelContext.fetch(registerDescriptor)
                        
                        if anyMatches.isEmpty {
                            // The username is good!
                            // You can initialize a new user here
                            
                            // Now check if the password is good
                            // Next, ensure password
                            if registerPassword1 != registerPassword2 {
                                registerText = "Make sure your password is input correctly."
                            }
                            else {
                                let newUser = User(id: UUID(), username: registerUsername, password: registerPassword1)
                                
                                modelContext.insert(newUser)
                                
                                isRegistering = false   // Setting this false should take it back to login view
                            }
                        }
                        else {
                            registerText = "Username is taken! Please try again"
                            registerUsername = ""
                            registerPassword1 = ""
                            registerPassword2 = ""
                        }
                    }
                    catch {
                        registerText = "There was some issue confirming your username. Please try again."
                        
                        // Debug text
                        print("There was some issue confirming your username. Please try again.")
                    }
                }
            }
        }
        else if !loggedIn {
            // have a login view
            VStack {
                Text(loginText)
                    .padding()
                    .frame(width: 400)
                    .multilineTextAlignment(.center)
                    

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Login") {
                    authenticateUser(username: username, password: password)
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                
                Button("New User? Register Here") {
                    isRegistering = true
                }
                
            }
        }
        else if !showCreateHuntView {
            VStack {
                MapReader { proxy in
                    Map(position: $manager.mapRegion, interactionModes: .all) {
                        // Have to request User Location
                        UserAnnotation()
                        
                        if currentHuntInView != "" && placedGuessMarkers[currentHuntInView] == true {
                            Annotation("My Guess", coordinate: CLLocationCoordinate2D(latitude: guessLatitudeCoordinate, longitude: guessLongitudeCoordinate)) {
                                Image(systemName: "flag")
                                    .padding(4)
                                    .foregroundStyle(.white)
                                    .background(Color.indigo)
                                    .cornerRadius(4.0)
                            }
                        }
                    }
                    .onTapGesture { position in
                        if placedGuessMarkers[currentHuntInView] == false {
                            placedGuessMarkers[currentHuntInView] = true
                            if let coordinate = proxy.convert(position, from: .local) {
                                print(coordinate)
                                
                                guessLatitudeCoordinate = coordinate.latitude
                                guessLongitudeCoordinate = coordinate.longitude
                                
                                // Place marker at position
                            }
                        }
                    }
                }
                
                NavigationSplitView {
                    List {
                        ForEach (currentUserHunts) { item in
                            NavigationLink(destination: ScavengerHuntView(currentUser: $currentUser, userGuessLatitude: $guessLatitudeCoordinate, userGuessLongitude: $guessLongitudeCoordinate, placedGuessMarkers: $placedGuessMarkers, currentHunt: $currentHuntInView, datePosted: item.datePosted, huntName: item.huntTitle, huntDescription: item.huntDescription, levelHints: item.levelsHints, levelVerificationCodes: item.levelVerificationCodes, numPeopleCompleted: item.numPeopleCompleted, huntLatitude: item.huntLatitude, huntLongitude: item.huntLongitude, numLevels: item.numLevels), tag: item, selection: $selectedHunt) {
                                Text("\(item.huntTitle)")
                            }
                            
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Text("Total Score for \(currentUser.username): \(currentUser.totalPoints)")
                            EditButton()
                        }
                    }
                    .navigationTitle("Stanford Scavenger Hunt")
                    
                    // This is where the user could add a hunt to their view of hunts
                    Text("Add a hunt!")
                        .padding(20)
                    List {
                        ForEach (hunts) { item in
                            Button(item.huntTitle) {
                                
                                // Add this hunt to the user's list of hunts if it's not already in their list of hunts
                                let targetHuntName = item.huntTitle
                                var hunts = currentUser.userHunts
                                
                                if !hunts.keys.contains(where: {$0.contains(targetHuntName)} ) {
                                    
                                    currentUser.addHunt(hunt: item)
                                    // Just reset the variable here (everytime you add a hunt)
                                    placedGuessMarkers = currentUser.placedMarkerForHunts
                                    print("Added")
                                    // Add this to the ScavengerHuntList so it appears in the user's directory of hunts
                                    let huntPredicate = #Predicate<ScavengerHunt> {
                                        $0.huntTitle == targetHuntName
                                    }
                                    
                                    let huntDescriptor = FetchDescriptor<ScavengerHunt>(predicate: huntPredicate)
                                    
                                    do {
                                        let currScavengerHunt = try modelContext.fetch(huntDescriptor)
                                        currentUserHunts.append(contentsOf: currScavengerHunt)
                                    }
                                    catch {
                                        print("There was an error loading the user's current hunts.")
                                    }
                                    
                                }
                                else {
                                    print("User is already added to hunt.")
                                }
                                
                            }
                        }
                    }
                    
                    Button("Create New Hunt") {
                        // Change Boolean to switch view
                        showCreateHuntView.toggle()
                        manager.mapRegion = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.42749137163412, longitude: -122.17028175677483), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                    }
                    
                    
                    
                    /*
                    Button("Test/Debug Button") {
                        // currentUser.totalPoints = 10
                    }
                    */

                } detail: {
                    if let hunt = selectedHunt {
                        ScavengerHuntView(currentUser: $currentUser, userGuessLatitude: $guessLatitudeCoordinate, userGuessLongitude: $guessLongitudeCoordinate, placedGuessMarkers: $placedGuessMarkers, currentHunt: $currentHuntInView, datePosted: hunt.datePosted, huntName: hunt.huntTitle, huntDescription: hunt.huntDescription, levelHints: hunt.levelsHints, levelVerificationCodes: hunt.levelVerificationCodes, numPeopleCompleted: hunt.numPeopleCompleted, huntLatitude: hunt.huntLatitude, huntLongitude: hunt.huntLongitude, numLevels: hunt.numLevels)
                    }
                    else {
                        Text("Choose a Hunt!")
                    }
                    /*
                    Text("Hunt Overview")
                    .navigationTitle("Detail")
                    */
                    
                    
                }
            }
            
            
        }
        else {
            // Put map and form view here
            MapReader { proxy in
                Map(position: $manager.mapRegion, interactionModes: .all) {
                    
                    UserAnnotation()
                    if placedMarker {
                        // Add annotation to this map
                        Annotation(huntTitle, coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitudeText)!, longitude: CLLocationDegrees(longitudeText)!)) {
                            Image(systemName: "flag")
                                .padding(4)
                                .foregroundStyle(.white)
                                .background(Color.indigo)
                                .cornerRadius(4.0)
                        }
                    }
                }
                .onTapGesture { position in
                    if !placedMarker {
                        placedMarker.toggle()
                        if let coordinate = proxy.convert(position, from: .local) {
                            print(coordinate)
                            latitudeText = String(coordinate.latitude)
                            longitudeText = String(coordinate.longitude)
                            
                            // Place marker at position
                            
                            
                        }
                        
                    }
                }
            }
            
            NavigationSplitView {
                VStack {
                    ScrollView {
                        TextField("Enter the title of your hunt:", text: $huntTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("Enter the description of of your hunt:", text: $huntDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Text("Tap on the map to drop a pin at the location of the hunt")
                        
                        TextField("Latitude Coordinates", text: $latitudeText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("Longitude Coordinates", text: $longitudeText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Text("You can have up to 10 levels and you must have a hint for each level")
                        
                        
                        DisclosureGroup(
                            isExpanded: $isListHintsExpanded,
                            content: {
                                ScrollView {
                                    ForEach(1...10, id: \.self) { index in
                                        TextField("Hint for level \(index)", text: Binding(
                                            get: {self.levelHints[index, default: ""]},
                                            set: {self.levelHints[index] = $0}
                                        ))
                                        
                                    }
                                    
                                }
                                
                            },
                            label: {
                                HStack {
                                    Image(systemName: isListHintsExpanded ? "chevron.up" : "chevron.right")
                                    Text("Hints")
                                }
                            }
                            
                        )
                        .padding()
                        .navigationTitle("Create New Scavenger Hunt")
                        // Have a button that sends the information back
                        
                        
                        HStack {
                            Button("Submit Hunt") {
                                // Cover the verification from
                                
                                let levelVerificationCodesInts = levelVerificationCodes.compactMapValues {
                                    Int($0)
                                }
                                
                                // Maybe set the variables here.
                                print(huntTitle)
                                print(huntDescription)
                                print(levelHints)
                                print(levelVerificationCodesInts)
                                print(latitudeText)
                                print(longitudeText)
                                
                                
                                addScavengerHunt(data: (huntTitle, huntDescription, levelHints, levelVerificationCodesInts, latitudeText, longitudeText))
                                
                                manager.mapRegion = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.42749137163412, longitude: -122.17028175677483), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                                
                                // reset all the variables
                                huntTitle = ""
                                huntDescription = ""
                                levelHints = [:]
                                levelVerificationCodes = [:]
                                latitudeText = ""
                                longitudeText = ""
                                placedMarker.toggle()
                                showCreateHuntView.toggle()
                            }
                            .padding()
                            
                            Button("Cancel") {
                                // reset all the variables
                                huntTitle = ""
                                huntDescription = ""
                                levelHints = [:]
                                levelVerificationCodes = [:]
                                latitudeText = ""
                                longitudeText = ""
                                placedMarker.toggle()
                                showCreateHuntView.toggle()
                                
                                manager.mapRegion = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.42749137163412, longitude: -122.17028175677483), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                                
                            }
                        }
                    }
                }
                .navigationTitle("Create Hunt")
            } detail: {
                Text("Create Hunt")
                .navigationTitle("Detail")
            }
        }
        
        /*
        NavigationSplitView {
            NavigationLink("Create New Hunt", destination: CreateScavengerHuntView { data in
                self.listOfData = data
                self.addScavengerHunt(data: data)
            })
            
            
            
            Button("Print Most Recent Hunt") {
                addScavengerHunt(data: self.listOfData)
            }
            
            
            
            
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                
                // Add an option to add a scavenger hunt here
                
                ToolbarItem {
                    
                }
                 
            }
        } detail: {
            Text("Select an item")
        }
         */
    }
    
    func authenticateUser(username: String, password: String) {
        
        // Ensure neither username nor the password are the empty string
        if username == "" || password == "" {
            loginText = "Your username or password cannot be left empty"
        }
        else {
            // create fetch predicate
            let loginPredicate = #Predicate<User> {
                $0.username == username &&
                $0.password == password
            }
            
            let loginDescriptor = FetchDescriptor<User>(predicate: loginPredicate)
            
            do {
                let currUser = try modelContext.fetch(loginDescriptor)
                if currUser.isEmpty {
                    loginText = "The username or password is incorrect. Please try again."
                }
                else {
                    loginText = "Success"
                    loggedIn = true
                    // maybe do some other logic here
                    // Set the current user to the one that just logged in
                    currentUser = currUser[0]
                    
                    // Set the currentUserHunts variable here
                    // iterate over the user hunts
                    let hunts = currentUser.userHunts
                    for huntTitle in hunts.keys {
                        let huntPredicate = #Predicate<ScavengerHunt> {
                            $0.huntTitle == huntTitle
                        }
                        
                        let huntDescriptor = FetchDescriptor<ScavengerHunt>(predicate: huntPredicate)
                        
                        do {
                            let currScavengerHunt = try modelContext.fetch(huntDescriptor)
                            currentUserHunts.append(contentsOf: currScavengerHunt)
                        }
                        catch {
                            print("There was an error loading the user's current hunts.")
                        }
                        
                    }
                    
                    // Set the placedGuessMarkers here:
                    placedGuessMarkers = currentUser.placedMarkerForHunts
                    print(placedGuessMarkers)
                    
                }
            } catch {
                loginText = "There was an error retrieving the username or login"
                
                print("There was an error retrieving the username or login")    // For debugging
            }
        }
        
        
        /*
        if let validPassword = Credentials.validCredentials[username], validPassword == password {
            loggedIn = true
        } else {
            // Handle incorrect credentials
            print("Incorrect username or password")
        }
         */
    }

    func addScavengerHunt(data: (String, String, [Int:String], [Int:Int], String, String)) {
        print(data)
        // Add the Scavenger Hunt to the modelContext (for SwiftData usage)
        // The last two strings need to be converted to CLLocationDegrees
        
        let newHunt = ScavengerHunt(timestamp: Date(), huntTitle: data.0, huntDescription: data.1, levelHints: data.2, levelVerificationCodes: data.3, huntLatitude: CLLocationDegrees(data.4)!, huntLongitude: CLLocationDegrees(data.5)!)
       
        modelContext.insert(newHunt)
    }
    
    /*
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
     */
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(hunts[index])
            }
        }
    }
     
}


#Preview {
    ContentView()
        .modelContainer(for: ScavengerHunt.self, inMemory: true)
}
