//
//  NetworkingManager.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 25/11/2021.
//

import UIKit
import RxSwift
import Alamofire

class NetworkingManager {
    
    struct NetworkAlert {
        init(_ title: String = "Oops!!", message: String) {
            self.title = title
            self.message = message
        }
        
        let title: String
        let message: String
    }
    
    static let shared = NetworkingManager()
    public let cache = NSCache<NSString, UIImage>()
    
    private let baseUrl = "https://api.github.com/users/"
    private let decoder = JSONDecoder()
    
    init() {
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    
    func getFollowers(for username: String, page: Int) -> Observable<[Follower]> {
        return Observable.create { observer -> Disposable in
            AF.request(self.baseUrl + "\(username)/followers?per_page=10&page=\(page)")
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            observer.onError(response.error ?? GHSearchError.notFound)
                            return
                        }
                        do {
                            let friend = try self.decoder.decode([Follower].self, from: data)
                            observer.onNext(friend)
                        } catch {
                            observer.onError(error)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }
    }
    
    func getFollowing(for username: String, page: Int) -> Observable<[Follower]> {
        return Observable.create { observer -> Disposable in
            AF.request(self.baseUrl + "\(username)/following?per_page=10&page=\(page)")
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            observer.onError(response.error ?? GHSearchError.notFound)
                            return
                        }
                        do {
                            let following = try self.decoder.decode([Follower].self, from: data)
                            observer.onNext(following)
                        } catch {
                            observer.onError(error)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }
    }
    
    func getUserInfo(for username: String) -> Observable<User> {
        return Observable.create { observer -> Disposable in
            AF.request(self.baseUrl + "\(username)")
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            observer.onError(response.error ?? GHSearchError.notFound)
                            return
                        }
                        do {
                            let friend = try self.decoder.decode(User.self, from: data)
                            observer.onNext(friend)
                        } catch {
                            observer.onError(error)
                        }
                    case .failure(let error):
                        print(error)
                        observer.onError(error)
                    }
                }
            return Disposables.create()
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
    
    
    func getResource<T: Decodable>(url: String) -> Observable<T> {
        return Observable.create { observer -> Disposable in
            AF.request(url)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            observer.onError(response.error ?? GHSearchError.notFound)
                            return
                        }
                        do {
                            let result = try self.decoder.decode(T.self, from: data)
                            observer.onNext(result)
                        } catch {
                            observer.onError(error)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }
    }    
}
