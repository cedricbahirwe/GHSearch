//
//  GHSearchError.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 25/11/2021.
//

import Foundation

enum GHSearchError: String, Error {
    case invalidUsername = "This username created an invalid request. Please try again."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again."
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case unableToSave = "There was an error saving this user. Please try again."
    case alreadyInBookmarks = "You've already saved this user!"
    case notFound = "unable to find the resource you're requesting."
}
