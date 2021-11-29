//
//  DataFetchingActivityVC.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import UIKit


class DataFetchingActivityVC: UIViewController {
    
    var contentView: UIView!
    
    func startLoadingActivityView() {
        contentView = UIView(frame: view.bounds)
        view.addSubview(contentView)
        
        contentView.backgroundColor = .systemBackground
        contentView.alpha = 0
        
        UIView.animate(withDuration: 0.25) { self.contentView.alpha = 0.8 }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        contentView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func stopLoadingActivityView() {
        if contentView != nil {
            contentView.removeFromSuperview()
        }
    }
    
    func presentEmptyView(with message: String) {
        
        presentAlert(title: "", message: message, buttonTitle: "Got it")
    }
}

