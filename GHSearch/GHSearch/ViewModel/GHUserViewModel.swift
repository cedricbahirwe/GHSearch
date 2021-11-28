//
//  GHUserViewModel.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import Foundation
import RxSwift
import RxCocoa

class GHUserViewModel {
//    var username: String = ""

    var selectedUser = BehaviorRelay<User?>(value: nil)
    
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
    
}
