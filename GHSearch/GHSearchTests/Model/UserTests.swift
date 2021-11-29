//
//  UserTests.swift
//  GHSearchTests
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import XCTest

typealias JSON = Dictionary<String, Any>

class UserTests: XCTestCase {

    func testSuccessfulInit() {
        let testSuccessfulJSON: JSON = [
            "login": "cedricbahirwe",
            "name": "Cédric Bahirwe",
            "avatar_url": "https://avatars.githubusercontent.com/u/49038614?v=4",
            "html_url": "https://github.com/cedricbahirwe",
            "bio": "IOS Developer, SwiftUI Evangelist ~ ReactJs Enthusiast",
            "public_repos": 71,
            "public_gists": 20,
            "followers": 18,
            "following": 45,
        ]

        XCTAssertNotNil(User(json: testSuccessfulJSON))
    }
}


// MARK: - User Extension
private extension User {
    init?(json: JSON) {
        guard let username = json["login"] as? String,
              let name = json["name"] as? String,
              let avatarUrl = json["avatar_url"] as? String,
              let location = json["location"] as? String?,
              let bio = json["bio"] as? String,
              let followers = json["followers"] as? Int,
              let followings = json["following"] as? Int,
              let publicRepos = json["public_repos"] as? Int,
              let publicGists = json["public_gists"] as? Int,
              let htmlUrl = json["html_url"] as? String else {
                  return nil
              }
        self.login = username
        self.name = name
        self.avatarUrl = avatarUrl
        self.location = location
        self.bio = bio
        self.publicRepos = publicRepos
        self.publicGists = publicGists
        self.htmlUrl = htmlUrl
        self.followers = followers
        self.following = followings
        self.createdAt = Date()
        
    }
}

