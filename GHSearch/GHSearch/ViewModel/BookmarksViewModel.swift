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
        
    }
}
