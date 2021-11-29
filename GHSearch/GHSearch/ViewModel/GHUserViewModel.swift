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
    
    
    func getFollows(typeof followType: FollowActivityType, username: String, page: Int = 1) {
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
    
    
    func delete(bookmarkedUser: UserCellViewModel) {
        
        PersistenceManager.updateBookmarks(with: bookmarkedUser, actionType: .remove) { [self] error in
            
            guard let error = error else {
                self.bookmarkedUsers.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            
            DispatchQueue.main.async {
                presentAlert(title: "Unable to remove", message: error.rawValue, buttonTitle: "OK")
            }
        }
//            .deleteFriend(id: friend.id)
//            .subscribe(
//                onNext: { [weak self] friends in
//                    self?.getFriends()
//                },
//                onError: { [weak self] error in
//                    let okAlert = SingleButtonAlert(
//                        title: (error as? AppServerClient.DeleteFriendFailureReason)?.getErrorMessage() ?? "Could not connect to server. Check your network and try again later.",
//                        message: "Could not remove \(friend.firstname) \(friend.lastname).",
//                        action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
//                    )
//                    self?.onShowError.onNext(okAlert)
//                }
//            )
//            .disposed(by: disposeBag)
    }
    
}
