//
//  MockUser.swift
//  GHSearchTests
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import Foundation

extension User {
    static func with(login: String = "John",
                     name: String = "John Smith",
                     avatarUrl: String = "",
                     location: String? = nil,
                     bio: String? = nil,
                     publicRepos: Int = 1,
                     publicGists: Int = 1,
                     htmlUrl: String = "",
                     following: Int = 0,
                     followers: Int = 0,
                     createdAt: Date = Date()) -> User
    {
        
        return User(login: login, name: name, avatarUrl: avatarUrl, location: location, bio: bio, publicRepos: publicRepos, publicGists: publicGists, htmlUrl: htmlUrl, following: following, followers: followers, createdAt: createdAt)
    }
}
