//
//  NetworkingManager.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 25/11/2021.
//

import UIKit

// A singleton class for networking
final class NetworkingManager {
    
    static let shared = NetworkingManager()
    public let cache = NSCache<NSString, UIImage>()

    private let baseUrl = "https://api.github.com/users/"
    private let decoder = JSONDecoder()
    
    private init() {
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    
    func getFollowers(for username: String, page: Int) async throws -> [Follower] {
        let endpoint = baseUrl + "\(username)/followers?per_page=10&page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            throw GHSearchError.invalidUsername
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHSearchError.invalidResponse
        }
        
        do {
            return try decoder.decode([Follower].self, from: data)
        } catch {
            throw GHSearchError.invalidData
        }
    }
    
    func getFollowing(for username: String, page: Int) async throws -> [Follower] {
        let endpoint = baseUrl + "\(username)/following?per_page=10&page=\(page)"
        
        guard let url = URL(string: endpoint) else {
            throw GHSearchError.invalidUsername
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHSearchError.invalidResponse
        }
        
        do {
            return try decoder.decode([Follower].self, from: data)
        } catch {
            throw GHSearchError.invalidData
        }
    }
    
    func getUserInfo(for username: String) async throws -> User {
        let endpoint = baseUrl + "\(username)"
        guard let url = URL(string: endpoint) else { throw GHSearchError.invalidUsername }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw GHSearchError.invalidResponse }
//        if let json =  try? JSONSerialization.jsonObject(with: data, options: []) {
//            print("JSon", json)
//        }
        do {
            return try decoder.decode(User.self, from: data)
        } catch {
            throw GHSearchError.invalidData
        }
    }
    
    
    func downloadedImage(from urlString: String) async -> UIImage? {
        let cacheKey = NSString(string: urlString)
        if let image = cache.object(forKey: cacheKey) { return image }
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            self.cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            return nil
        }
    }
    
    
    
    
}
