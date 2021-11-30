//
//  GHUserViewModelTests.swift
//  GHSearchTests
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import XCTest
import RxSwift

class GHUserViewModelTests: XCTestCase {
    
    
    func testGetUserFailure() {
        let disposeBag = DisposeBag()
        let appServerClient = MockAppServerClient()
        let user = User.with()
        appServerClient.getUserResult = .failure(GHSearchError.notFound)

        let viewModel = GHUserViewModel(apiClient: appServerClient)

        let expectErrorShown = expectation(description: "Error note is shown")
        viewModel.onShowError.subscribe(
            onNext: { alert in
                expectErrorShown.fulfill()
            }).disposed(by: disposeBag)

        viewModel.getUserInfo(for: user.login)

        wait(for: [expectErrorShown], timeout: 0.1)
    }
    
    
}


private final class MockAppServerClient: NetworkingManager {
    var getFollowersResult: Result<[Follower], GHSearchError>?
    var getUserResult: Result<User, GHSearchError>?
    
    
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
