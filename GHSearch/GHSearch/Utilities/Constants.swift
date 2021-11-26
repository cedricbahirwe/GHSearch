//
//  Constants.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 25/11/2021.
//

import UIKit

enum ScreenSize {
    static let width        = UIScreen.main.bounds.size.width
    static let height       = UIScreen.main.bounds.size.height
    static let maxLength    = max(ScreenSize.width, ScreenSize.height)
    static let minLength    = min(ScreenSize.width, ScreenSize.height)
}


enum GHImages {
    static let imagePlaceholder = UIImage(named: "gitavatar-placeholder")
}
