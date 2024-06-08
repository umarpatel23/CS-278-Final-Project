//
//  CreateScavengerHuntView.swift
//  Scavenger Hunt Platform
//
//  Created by Umar Patel on 4/28/24.
//


// NOT USING THIS VIEW ANYMORE

import SwiftUI

struct CreateScavengerHuntView: View {
    var sendDataBack: ((String, String, [Int:String], [Int:Int])) -> Void
    @Environment(\.dismiss) private var dismiss
    
    // Create state variables to hold the input texts
    @State var huntTitle: String = ""
    @State var huntDescription: String = ""
    @State var levelHints: [Int:String] = Dictionary(uniqueKeysWithValues: (1...10).map {($0, "")})
    @State var levelVerificationCodes: [Int:String] = Dictionary(uniqueKeysWithValues: (1...10).map {($0, "")})
        
    @State private var isListHintsExpanded: Bool = false
    @State private var isListCodesExpanded: Bool = false
    
    
    
    var body: some View {
        VStack {
            ScrollView {
                TextField("Enter the title of your hunt:", text: $huntTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Enter the description of of your hunt:", text: $huntDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("You can have up to 10 hints for each level")
                
                DisclosureGroup(
                    isExpanded: $isListHintsExpanded,
                    content: {
                        ScrollView {
                            
                            ForEach(1...10, id: \.self) { index in
                                TextField("Hint \(index)", text: Binding(
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
                
                /*
                Text("Please upload the verification codes for each level. These codes can be found on site when you complete each level. They should be 4-digit values.")
                    .padding()
                
                Text("* Note that the number of entries in the hint tab must equal the number of entries in the verification codes tab")
                    .padding()
                
                DisclosureGroup(
                    isExpanded: $isListCodesExpanded,
                    content: {
                        ScrollView {
                            ForEach(1...10, id: \.self) {
                                index in TextField("Verification code for level \(index). Must be 4 digits", text: Binding(
                                    get: {self.levelVerificationCodes[index, default: ""]},
                                    set: {self.levelVerificationCodes[index] = $0}
                                ))
                            }
                        }
                    },
                    label: {
                        HStack {
                            Image(systemName: isListCodesExpanded ? "chevron.up" : "chevron.right")
                            Text("VerificationCodes")
                        }
                    }

                )
                */
                
                Button("Submit Hunt") {
                    // Cover the verification from
                    
                    let levelVerificationCodesInts = levelVerificationCodes.compactMapValues {
                        Int($0)
                    }
                    
                    sendDataBack((huntTitle, huntDescription, levelHints, levelVerificationCodesInts))
                    dismiss()
                }
            }
        }
        .navigationTitle("Create Hunt")
        // Text("This is where you create a scavenger hunt")
        
        
    }
}

/*
#Preview {
    CreateScavengerHuntView()
}
*/
