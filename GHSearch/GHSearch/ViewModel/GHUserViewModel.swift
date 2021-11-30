//
//  GHUserViewModel.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol UserInfoVCDelegate: AnyObject {
    func didRequestShowProfile(for username: String)
}

class GHUserViewModel: ObservableObject {
    
    var selectedUser = BehaviorRelay<User?>(value: nil)
    
    var followers = BehaviorRelay<[Follower]>(value: [])
    
    var followType: FollowActivityType? = nil
    var hasMoreFollowers = true
    let fetchMoreDatas = PublishSubject<Void>()
    let isLoadingSpinnerAvaliable = PublishSubject<Bool>()

    private var pageCounter = 1
    private var isPaginationRequestStillResume = false
    
    let onShowError = PublishSubject<GHSearchError>()
    
    let apiClient: NetworkingManager
    
    var onShowLoadingView: Observable<Bool> {
        return loadInProgress
            .asObservable()
            .distinctUntilChanged()
    }
    let disposeBag = DisposeBag()
    
    var delegate: UserInfoVCDelegate?
    
    
    private let loadInProgress = BehaviorRelay(value: false)

    init(apiClient: NetworkingManager = NetworkingManager()) {
        self.apiClient = apiClient
        bind()
    }
    
    
    private func bind() {
        fetchMoreDatas.subscribe { [weak self] _ in
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
        
        if isPaginationRequestStillResume { return }
        
        if hasMoreFollowers == false {
            isPaginationRequestStillResume = false
            return
        }
       
        isPaginationRequestStillResume = true
        isLoadingSpinnerAvaliable.onNext(true)
        
        if pageCounter == 1 {
            isLoadingSpinnerAvaliable.onNext(false)
        }
        
        
        let followRequest = followType == .followers ? apiClient.getFollowers(for: username, page: page) : apiClient.getFollowing(for: username, page: page)
        
        followRequest
            .subscribe(
                onNext: { [weak self] newFollowers in
                    if page == 1 {
                        self?.followers.accept(newFollowers)
                    } else {
                        let oldFollowers = self?.followers.value ?? []
                        self?.followers.accept(oldFollowers + newFollowers)
                    }
                    
                    if newFollowers.count < 10 {
                        self?.hasMoreFollowers = false
                    }
                    
                    self?.isLoadingSpinnerAvaliable.onNext(false)
                    self?.isPaginationRequestStillResume = false
                    
                    self?.pageCounter += 1
                },
                onError: { [weak self] error in
                    self?.isLoadingSpinnerAvaliable.onNext(false)
                    self?.isPaginationRequestStillResume = false
                    self?.onShowError.onNext((error as? GHSearchError ?? GHSearchError.invalidResponse))
                }
            )
            .disposed(by: disposeBag)
    }
    
    func initializeFollowList() {
        followers.accept([])
        pageCounter = 1
        hasMoreFollowers = true
    }
    
}
