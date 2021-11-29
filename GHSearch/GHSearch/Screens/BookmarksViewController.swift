//
//  BookmarksViewController.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 29/11/2021.
//

import UIKit

class BookmarksViewController: DataFetchingActivityVC {
    var userViewModel: GHUserViewModel?
    
    private let tableView = UITableView()
    private var bookmarkedUsers: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getBookmarkedUsers()
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Bookmarks"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BookmarkCell.self, forCellReuseIdentifier: String(describing: BookmarkCell.self))
    }
    
    func getBookmarkedUsers() {
        PersistenceManager.retrieveBookmarks { [self] result in
            
            switch result {
            case .success(let users):
                self.updateUILayout(with: users)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "OK")
                }
            }
        }
    }
    
    func updateUILayout(with users: [User]) {
        if users.isEmpty {
            presentAlert(title: "Oops!", message: "You have not bookmarked any user yet!", buttonTitle: "Got it!")
        } else {
            self.bookmarkedUsers = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension BookmarksViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BookmarkCell.self)) as! BookmarkCell
        let user = bookmarkedUsers[indexPath.row]
        cell.set(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = bookmarkedUsers[indexPath.row]
        let userProfileVC = UserProfileViewController(username: user.login, userViewModel: userViewModel!)
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else { return }
        
        PersistenceManager.updateBookmarks(with: bookmarkedUsers[indexPath.row], actionType: .remove) { [self] error in
            
            guard let error = error else {
                self.bookmarkedUsers.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            
            DispatchQueue.main.async {
                presentAlert(title: "Unable to remove", message: error.rawValue, buttonTitle: "Dismiss")
            }
        }
    }
}
