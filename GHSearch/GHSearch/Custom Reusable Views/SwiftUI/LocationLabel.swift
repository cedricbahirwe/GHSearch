//
//  LocationLabel.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import SwiftUI

struct LocationLabel: View {
    let description: String
    init(_ description: String) { self.description = description }
    var body: some View {
        Label(description, systemImage: "mappin.and.ellipse")
    }
}

struct LocationLabel_Previews: PreviewProvider {
    static var previews: some View {
        LocationLabel("Location")
    }
}
