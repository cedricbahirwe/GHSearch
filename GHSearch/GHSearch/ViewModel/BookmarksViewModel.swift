//
//  BookmarksViewModel.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 28/11/2021.
//

import Foundation
import RxSwift
import RxCocoa

class BookmarksViewModel {
    
    var users = BehaviorRelay<[Follower]>(value: [])
    
    let onShowError = PublishSubject<NetworkingManager.NetworkAlert>()
    
    func getBookmarkedUsers() {
        PersistenceManager.retrieveBookmarks { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let users):
                self.updateUILayout(with: users)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
                }
            }
        }
    }
}
