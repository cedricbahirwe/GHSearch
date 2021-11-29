//
//  User.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 25/11/2021.
//

import Foundation

struct User: Codable, Hashable {
    let login: String
    var name: String?
    let avatarUrl: String
    var location: String?
    var bio: String?
    let publicRepos: Int
    let publicGists: Int
    let htmlUrl: String
    let following: Int
    let followers: Int
    let createdAt: Date
    
    static let example = User(login: "safeboda", name: Optional("SafeBoda"), avatarUrl: "https://avatars.githubusercontent.com/u/49038614?v=4", location: nil, bio: Optional("IOS Developer, SwiftUI Evangelist ~ ReactJs Enthusiast"), publicRepos: 71, publicGists: 20, htmlUrl: "https://github.com/cedricbahirwe", following: 45, followers: 18, createdAt: Date(timeIntervalSinceNow: -84_130_121))
}
