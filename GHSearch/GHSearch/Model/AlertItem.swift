//
//  AlertItem.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 26/11/2021.
//

import Foundation

struct GHAlertItem: Identifiable {
    var id = UUID()
    var title: String = "Something went wrong"
    var message: String?
}
