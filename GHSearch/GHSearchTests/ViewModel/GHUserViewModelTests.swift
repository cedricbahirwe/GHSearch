//
//  GHUserViewModelTests.swift
//  GHSearchTests
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import XCTest
import RxSwift
@testable import GHSearch

class GHUserViewModelTests: XCTestCase {
    
//    func testAddFriendSuccess() {
//        let disposeBag = DisposeBag()
//        let appServerClient = MockAppServerClient.shared
//        appServerClient.getFollowersResult = .success([]) // .success(payload: ([User.with()]))
//
//        let viewModel =  GHUserViewModel(apiClient: appServerClient)
//
//        let mockUser = User.with()
////        viewModel.firstname.accept(mockFriend.firstname)
////        viewModel.lastname.accept(mockFriend.lastname)
////        viewModel.phonenumber.accept(mockFriend.phonenumber)
//
//        let expectNavigateCall = expectation(description: "Navigate back is called")
//
//        viewModel.onNavigateBack.asObservable().debug().subscribe(
//            onNext: { _ in
//                expectNavigateCall.fulfill()
//            }
//        ).disposed(by: disposeBag)
//
//        viewModel.submitButtonTapped.onNext(())
//
//        wait(for: [expectNavigateCall], timeout: 0.1)
//    }
    
//    func testAddFriendFailure() {
//        let disposeBag = DisposeBag()
//        let appServerClient = MockAppServerClient()
//        appServerClient.postUserResult = .failure(AppServerClient.PostFriendFailureReason(rawValue: 401))
//
//        let viewModel = AddFriendViewModel(appServerClient: appServerClient)
//
//        let mockFriend = Friend.with()
//        viewModel.firstname.accept(mockFriend.firstname)
//        viewModel.lastname.accept(mockFriend.lastname)
//        viewModel.phonenumber.accept(mockFriend.phonenumber)
//
//        let expectErrorShown = expectation(description: "OnShowError is called")
//
//        viewModel.onShowError.asObservable().subscribe(
//            onNext: { singleButtonAlert in
//                expectErrorShown.fulfill()
//            }
//        ).disposed(by: disposeBag)
//
//        viewModel.submitButtonTapped.onNext(())
//
//        wait(for: [expectErrorShown], timeout: 0.1)
//    }
    
//    func testValidateInputSuccess() {
//        let disposeBag = DisposeBag()
//        let mockFriend = Friend.with()
//        let appServerClient = MockAppServerClient()
//
//        let viewModel = AddFriendViewModel(appServerClient: appServerClient)
//        viewModel.firstname.accept(mockFriend.firstname)
//        viewModel.lastname.accept(mockFriend.lastname)
//        viewModel.phonenumber.accept(mockFriend.phonenumber)
//
//        let expectUpdateSubmitButtonStateCall = expectation(description: "updateSubmitButtonState is called")
//
//        viewModel.submitButtonEnabled.subscribe(
//            onNext: { state in
//                guard state else { return }
//
//                expectUpdateSubmitButtonStateCall.fulfill()
//            }
//        ).disposed(by: disposeBag)
//
//        wait(for: [expectUpdateSubmitButtonStateCall], timeout: 0.1)
//    }
    
    
    func testGetUserFailure() {
        let disposeBag = DisposeBag()
        let user = User.with()
        let apiClient = MockAppServerClient()
        apiClient.getUserResult = .failure(GHSearchError.notFound)

        let viewModel = GHUserViewModel()
//
        let expectErrorShown = expectation(description: "Error note is shown")
        
        viewModel.onShowError.subscribe(
            onNext: { singleButtonAlert in
                expectErrorShown.fulfill()
            }).disposed(by: disposeBag)

        
        viewModel.getUserInfo(for: user.login)

        wait(for: [expectErrorShown], timeout: 0.1)
    }
}


private final class MockAppServerClient: NetworkingManager {
    var getFollowersResult: Result<[Follower], GHSearchError>?
    var getUserResult: Result<User, GHSearchError>?
    
//    static var sharedInstance = NetworkingManager.shared
    
    override func getFollowers(for username: String, page: Int) -> Observable<[Follower]> {
        
        return Observable.create { observer in
            switch self.getFollowersResult {
            case .success(let followers):
                observer.onNext(followers)
            case .failure(let error):
                observer.onError(error)
            case .none:
                observer.onError(GHSearchError.notFound)
            }

            return Disposables.create()
        }
    }

    override func getUserInfo(for username: String) -> Observable<User> {
        return Observable.create { observer in
            switch self.getUserResult {
            case .success(let user):
                observer.onNext(user)
            case .failure(let error):
                observer.onError(error)
            case .none:
                observer.onError(GHSearchError.notFound)
            }
            
            return Disposables.create()
        }
    }
}
