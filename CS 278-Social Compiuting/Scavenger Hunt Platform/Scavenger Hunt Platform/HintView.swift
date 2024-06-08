//
//  HintView.swift
//  Scavenger Hunt Platform
//
//  Created by Umar Patel on 4/28/24.
//

import SwiftUI

struct HintView: View {
    @Binding var currentHint: String
    var body: some View {
        Text("Hint: " + currentHint)
            .padding(20)
    }
}


/*
#Preview {
    HintView()
}
*/
