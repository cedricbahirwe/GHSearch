//
//  GHUserViewModel.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import Foundation
import RxSwift
import RxCocoa

class GHUserViewModel: ObservableObject {
    
    var selectedUser = BehaviorRelay<User?>(value: nil)
    
    var followers = BehaviorRelay<[Follower]>(value: [])
    var followType: FollowActivityType? = nil
    
    let onShowError = PublishSubject<GHSearchError>()
    
    let apiClient: NetworkingManager
    
    var onShowLoadingView: Observable<Bool> {
        return loadInProgress
            .asObservable()
            .distinctUntilChanged()
    }
    
    private let loadInProgress = BehaviorRelay(value: false)

    
    init(apiClient: NetworkingManager = NetworkingManager.shared) {
        self.apiClient = apiClient
    }
    
    let disposeBag = DisposeBag()
    
    func getUserInfo(for username: String) {
        loadInProgress.accept(true)

        apiClient
            .getUserInfo(for: username)
            .subscribe(
                onNext: { [weak self] userInfo in
                    print("Got response")
                    self?.loadInProgress.accept(false)
                    
                    self?.selectedUser.accept(userInfo)
                    
                },
                onError: { [weak self] error in
                    self?.loadInProgress.accept(false)
                    print("Never response")
                    self?.onShowError.onNext((error as? GHSearchError ?? GHSearchError.invalidResponse))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func getFollows(of followType: FollowActivityType, username: String, page: Int = 1) {
        loadInProgress.accept(true)

        let followRequest = followType == .followers ? apiClient.getFollowers(for: username, page: page) : apiClient.getFollowing(for: username, page: page)
        
        followRequest
            .subscribe(
                onNext: { [weak self] newFollowers in
                    self?.loadInProgress.accept(false)
                    if page == 1 {
                        self?.followers.accept(newFollowers)
                    } else {
                        self?.followers.accept(self!.followers.value  + newFollowers)
                    }
                },
                onError: { [weak self] error in
                    self?.loadInProgress.accept(false)
                    print("Never response")
                    self?.onShowError.onNext((error as? GHSearchError ?? GHSearchError.invalidResponse))
                }
            )
            .disposed(by: disposeBag)
    }
    
    
    private func getFollowers(username: String, page: Int) {
        loadInProgress.accept(true)

        apiClient
            .getFollowers(for: username, page: page)
            .subscribe(
                onNext: { [weak self] newFollowers in
                    self?.loadInProgress.accept(false)
                    if page == 1 {
                        self?.followers.accept(newFollowers)
                    } else {
                        self?.followers.accept(self!.followers.value  + newFollowers)
                    }
                },
                onError: { [weak self] error in
                    self?.loadInProgress.accept(false)
                    print("Never response")
                    self?.onShowError.onNext((error as? GHSearchError ?? GHSearchError.invalidResponse))
                }
            )
            .disposed(by: disposeBag)
        
    }
    
    
    private func getFollowing(username: String, page: Int) {
        loadInProgress.accept(true)

        apiClient
            .getFollowing(for: username, page: page)
            .subscribe(
                onNext: { [weak self] newFollowing in
                    self?.loadInProgress.accept(false)
                    if page == 1 {
                        self?.followers.accept(newFollowing)
                    } else {
                        self?.followers.accept(self!.followers.value  + newFollowing)
                    }
                },
                onError: { [weak self] error in
                    self?.loadInProgress.accept(false)
                    print("Never response")
//                    "Oops, No Followings!!!", message: "This user does not follow anyone🤷🏽‍♂️.", buttonTitle: "Okay"
                    self?.onShowError.onNext((error as? GHSearchError ?? GHSearchError.invalidResponse))
                }
            )
            .disposed(by: disposeBag)
        
    }
    
}
