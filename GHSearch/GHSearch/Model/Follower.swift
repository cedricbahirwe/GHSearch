//
//  Follower.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 25/11/2021.
//

import Foundation

struct Follower: Codable, Hashable, Identifiable {
    var id: String { login }    
    let login: String
    let avatarUrl: String
    let htmlUrl: String
}
