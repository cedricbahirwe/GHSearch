//
//  Date+Extension.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 26/11/2021.
//

import Foundation

extension Date {
    func convertingToMonthYear() -> String {
        formatted(.dateTime.month().year())
    }
}
