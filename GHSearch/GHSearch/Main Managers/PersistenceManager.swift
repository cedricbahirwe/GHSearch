//
//  PersistenceManager.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 25/11/2021.
//

import Foundation

enum PersistenceManager {
    
    enum PersistenceOperation {  case add, remove }
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let bookmarkedUsers = "bookmarkedUsers"
    }
    
    static func save(bookmarks: [User]) -> GHSearchError? {
        save(data: bookmarks, for: Keys.bookmarkedUsers)
    }
    
    static func retrieveBookmarks(completed: @escaping (Result<[User], GHSearchError>) -> Void) {
        retrieve(forKey: Keys.bookmarkedUsers, default: [], completion: completed)
    }
    
    static func updateBookmarks(with user: User, actionType: PersistenceOperation, completed: @escaping (GHSearchError?) -> Void) {
        retrieveBookmarks { result in
            switch result {
            case .success(var bookmarkedUsers):
                switch actionType {
                case .add:
                    guard !bookmarkedUsers.contains(user) else {
                        completed(.alreadyInBookmarks)
                        return
                    }
                    
                    bookmarkedUsers.append(user)
                    
                case .remove:
                    bookmarkedUsers.removeAll { $0.login == user.login }
                }
                
                completed(save(bookmarks: bookmarkedUsers))
                
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    private static func save<T>(data: T, for key: String) -> GHSearchError? where T: Codable {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            defaults.set(encodedData, forKey: key)
            return nil
        } catch {
            return .unableToSave
        }
    }
    
    private static func retrieve<T: Decodable>(forKey key: String, default: T? = nil,
                                               completion: @escaping (Result<T, GHSearchError>) ->  Void) {
        
        guard let decodedData = defaults.object(forKey: key) as? Data else {
            guard let defaultValue = `default` else {
                completion(.failure(.notFound))
                return
            }
            completion(.success(defaultValue))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: decodedData)
            completion(.success(result))
        } catch {
            completion(.failure(.invalidData))
        }
    }
}
