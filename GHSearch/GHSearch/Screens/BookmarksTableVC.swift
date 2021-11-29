//
//  BookmarksTableVC.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import UIKit

class BookmarksTableVC: UITableViewController {
    var userViewModel: GHUserViewModel!
    var users: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        getBookmarkedUsers()
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Bookmarks"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableViewCell() {
        tableView.rowHeight = 80
        tableView.register(BookmarkCell.self, forCellReuseIdentifier: String(describing: BookmarkCell.self))
    }
    
    func getBookmarkedUsers() {
        PersistenceManager.retrieveBookmarks { [self] result in
            
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
    
    func updateUILayout(with users: [User]) {
        if users.isEmpty {
            presentAlert(title: "Oops!", message: "You have not bookmarked any user yet!", buttonTitle: "Got it!")
        } else {
            self.users = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BookmarkCell.self)) as! BookmarkCell
        let user = users[indexPath.row]
        cell.set(user: user)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let userProfileVC = UserProfileViewController(username: user.login, userViewModel: userViewModel)
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else { return }
        
        PersistenceManager.updateBookmarks(with: users[indexPath.row], actionType: .remove) { [self] error in
            
            guard let error = error else {
                self.users.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            
            DispatchQueue.main.async {
                presentAlert(title: "Unable to remove", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
}
