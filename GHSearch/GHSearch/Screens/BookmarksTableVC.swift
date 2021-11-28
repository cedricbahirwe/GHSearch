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
//        tableView.removeExcessCells()
        
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
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    
    // Override to support editing the table view.
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


class BookmarkCell: UITableViewCell {
    
    let avatarImageView = GHAvatarImageView(frame: .zero)
    let usernameLabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(user: User) {
        avatarImageView.image = GHImages.imagePlaceholder
        avatarImageView.downloadImage(fromURL: user.avatarUrl)
        usernameLabel.text = user.login
    }
    
    private func configureLabel( _ label: UILabel) {
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.9
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    private func configure() {
        
        configureLabel(usernameLabel)
        
        contentView.addSubviews(avatarImageView, usernameLabel)
        accessoryType = .disclosureIndicator
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            
            usernameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            usernameLabel.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
}

class FavoritesListVC: DataFetchingActivityVC {
    
    let tableView = UITableView()
    var bookmarkedUsers: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.removeExcessCells()
        
        tableView.register(BookmarkCell.self, forCellReuseIdentifier: String(describing: BookmarkCell.self))
    }
    
    func getFavorites() {
        PersistenceManager.retrieveBookmarks { [weak self] result in
            guard let self = self else { return }
            
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
            self.bookmarkedUsers = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension FavoritesListVC: UITableViewDataSource, UITableViewDelegate {
    
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
        let userProfileVC = UserProfileViewController(username: user.login, userViewModel: GHUserViewModel())
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
                presentAlert(title: "Unable to remove", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
}
