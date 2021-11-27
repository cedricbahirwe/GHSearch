//
//  UIViewController+Extension.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 26/11/2021.
//

import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String, buttonTitle: String = "OK", dismissAction: (() -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: buttonTitle, style: .default) { _ in
            dismissAction?()
        }
        
        alertVC.addAction(dismissAction)
        self.present(alertVC, animated: true)
    }
    
    func presentUnknownError() {
        presentAlert(title: "Something Went Wrong",
                     message:  "We were unable to complete your request at this time. Please try again.",
                     buttonTitle: "OK")
    }
}

