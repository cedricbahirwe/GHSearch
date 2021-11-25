//
//  PersistenceManager.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 25/11/2021.
//

import Foundation

enum PersistenceManager {
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let followers = "followers"
        static let user = "user"
    }
    
    static func save(followers: [Follower]) -> GHSearchError? {
        save(data: followers, for: Keys.followers)
    }
    
    static func save(user: User) -> GHSearchError? {
        save(data: user, for: Keys.user)
    }
    
    static func retrieveFollowers(completed: @escaping (Result<[Follower], GHSearchError>) -> Void) {
        retrieve(forKey: Keys.followers, completion: completed)
    }
    
    static func retrieveUser(completed: @escaping (Result<User, GHSearchError>) -> Void) {
        retrieve(forKey: Keys.user, completion: completed)
    }
    
    
    private static func save<T>(data: T, for key: String) -> GHSearchError? where T: Codable {
        do {
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(data)
            defaults.set(encodedFavorites, forKey: key)
            return nil
        } catch {
            return .unableToSave
        }
    }
    
    private static func retrieve<T: Decodable>(forKey key: String,
                                               completion: @escaping (Result<T, GHSearchError>) ->  Void) {
        
        guard let favoritesData = defaults.object(forKey: key) as? Data else {
            completion(.failure(.notFound))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: favoritesData)
            completion(.success(result))
        } catch {
            completion(.failure(.invalidData))
        }
    }
    
}

