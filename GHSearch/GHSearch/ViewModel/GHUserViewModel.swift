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
    let fetchMoreFollowers = PublishSubject<Void>()
    let showFollowersListSpinner = PublishSubject<Bool>()
    var followType: FollowActivityType? = nil
    private var pageCounter = 1
    var hasMoreFollowers = true
    
    let onShowError = PublishSubject<GHSearchError>()
    
    let apiClient: NetworkingManager
    
    var onShowLoadingView: Observable<Bool> {
        return loadInProgress
            .asObservable()
            .distinctUntilChanged()
    }
    let disposeBag = DisposeBag()
    
    private let loadInProgress = BehaviorRelay(value: false)

    init(apiClient: NetworkingManager = NetworkingManager.shared) {
        self.apiClient = apiClient
        bind()
    }
    
    
    private func bind() {
        fetchMoreFollowers.subscribe { [weak self] _ in
            guard let self = self,
                  let user = self.selectedUser.value,
                  let followType = self.followType else { return }
            self.getFollows(typeof: followType, username: user.login, page: self.pageCounter)
        }
        .disposed(by: disposeBag)
        
    }
    
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
                    print("Error response")
                    self?.onShowError.onNext((error as? GHSearchError ?? GHSearchError.invalidResponse))
                }
            )
            .disposed(by: disposeBag)
    }
    
    
    func getFollows(typeof followType: FollowActivityType, username: String, page: Int = 1) {
        self.followType = followType
        guard hasMoreFollowers, !loadInProgress.value else { return }
        
        showFollowersListSpinner.onNext(true)
        
        if page == 1 {
            showFollowersListSpinner.onNext(false)
        }
        pageCounter += 1

        let followRequest = followType == .followers ? apiClient.getFollowers(for: username, page: page) : apiClient.getFollowing(for: username, page: page)
        
        followRequest
            .subscribe(
                onNext: { [weak self] newFollowers in
                    self?.showFollowersListSpinner.onNext(false)
                    if page == 1 {
                        self?.followers.accept(newFollowers)
                    } else {
                        let oldFollowers = self?.followers.value ?? []
                        self?.followers.accept(oldFollowers + newFollowers)
                    }
                    
                    if newFollowers.count < 10 {
                        self?.hasMoreFollowers = false
                    }
                    
                    
                },
                onError: { [weak self] error in
                    self?.showFollowersListSpinner.onNext(false)
                    print("Never response")
                    self?.onShowError.onNext((error as? GHSearchError ?? GHSearchError.invalidResponse))
                }
            )
            .disposed(by: disposeBag)
    }
    
    
//    private func getFollowers(username: String, page: Int) {
//        loadInProgress.accept(true)
//
//        apiClient
//            .getFollowers(for: username, page: page)
//            .subscribe(
//                onNext: { [weak self] newFollowers in
//                    self?.loadInProgress.accept(false)
//                    if page == 1 {
//                        self?.followers.accept(newFollowers)
//                    } else {
//                        self?.followers.accept(self!.followers.value  + newFollowers)
//                    }
//                },
//                onError: { [weak self] error in
//                    self?.loadInProgress.accept(false)
//                    print("Never response")
//                    self?.onShowError.onNext((error as? GHSearchError ?? GHSearchError.invalidResponse))
//                }
//            )
//            .disposed(by: disposeBag)
//
//    }
    
    
//    private func getFollowing(username: String, page: Int) {
//        loadInProgress.accept(true)
//
//        apiClient
//            .getFollowing(for: username, page: page)
//            .subscribe(
//                onNext: { [weak self] newFollowing in
//                    self?.loadInProgress.accept(false)
//                    if page == 1 {
//                        self?.followers.accept(newFollowing)
//                    } else {
//                        self?.followers.accept(self!.followers.value  + newFollowing)
//                    }
//                    if newFollowing.count < 10 {
//                        self?.hasMoreFollowers = false
//                    }
//                },
//                onError: { [weak self] error in
//                    self?.loadInProgress.accept(false)
//                    print("Never response")
////                    "Oops, No Followings!!!", message: "This user does not follow anyone🤷🏽‍♂️.", buttonTitle: "Okay"
//                    self?.onShowError.onNext((error as? GHSearchError ?? GHSearchError.invalidResponse))
//                }
//            )
//            .disposed(by: disposeBag)
//
//    }
    
    
    func initializeFollowList() {
        followers.accept([])
        pageCounter = 1
        hasMoreFollowers = true
    }
    
}
