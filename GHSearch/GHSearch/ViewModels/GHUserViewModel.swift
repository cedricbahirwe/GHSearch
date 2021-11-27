//
//  GHUserViewModel.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import Foundation
import RxSwift


class GHUserViewModel {
    var username: String = ""
    var user: User!
    
    let showError = PublishSubject<Any>()
    
    let disposeBag = DisposeBag()
    
    private let loadInProgress = false
    
}
