//
//  SearchViewController.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 26/11/2021.
//

import UIKit
import SwiftUI

class SearchViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    
    var isUsernameEntered: Bool { !usernameTextField.text!.isEmpty }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        createDismissKeyboardTapGesture()
        
//        getUserInfo()
    }
    
    func getUserInfo() {
        Task {
            do {
                let user = try await NetworkingManager.shared.getUserInfo(for: usernameTextField.text!)
                print("User", user)
                
            } catch {
                print("There is a error")
                if let ghError = error as? GHSearchError {
                    presentAlert(title: "Something went wrong", message: ghError.rawValue, buttonTitle: "OK") {
                        self.dismiss(animated: true)
                    }
                } else {
                    print("Crazy")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameTextField.applyRoundedStyle()
        usernameTextField.text = "cedricbahirwe"

        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func didPressGetProfile(_ sender: UIButton) {
        pushProfileVC()
    }
    
    
    private func pushProfileVC() {
        guard isUsernameEntered else {
            presentAlert(title: "Empty Username",
                         message: "Please enter a username",
                         buttonTitle: "OK")
            return
        }
        
        usernameTextField.resignFirstResponder()
        
        let userProfileView = UserProfileView(user: .example,
                                              onRequestFollowers: { _ in },
                                              onRequestFollowing: { _ in })
        
        let userProfileVC = UIHostingController(rootView: userProfileView)

//        let userProfileVC = UserProfileViewController(username: usernameTextField.text!)
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    
    func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushProfileVC()
        return true
    }
}
