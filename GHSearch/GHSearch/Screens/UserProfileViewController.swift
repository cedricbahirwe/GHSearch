//
//  UserProfileViewController.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 26/11/2021.
//

import UIKit
import SwiftUI

protocol UserInfoVCDelegate: AnyObject {
    func didRequestFollowers(for username: String, page: Int)
    
    func didRequestShowProfile(for username: String)
}

class UserProfileViewController: DataFetchingActivityVC {
    
    enum FollowActivityType {
        case follower, following
        var title: String {
            switch self {
            case .follower:
                return "Followers"
            case .following:
                return "Followings"
            }
        }
    }
    
    enum Section {
        case main
    }
    
    var username: String!
    var user: User!
    
//    var page = 1
//    var hasMoreFollowers = true
//    var isSearching = false
//    var isLoadingMoreFollowers = false
//
//    var collectionView: UICollectionView!
//    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!

//    var userProfileView: UserProfileView!
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username = username
        title = username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        getUserInfo(username: username)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    
    func configureUserProfileView(user: User) {
        title =  user.login
        view.subviews.forEach { $0.removeFromSuperview() }
        let userProfileView = UserProfileView(user: user,
                                              onRequestFollowers: getFollowers,
                                              onRequestFollowing: getFollowings)
        
        let childView = UIHostingController(rootView: userProfileView)
        addChild(childView)
        childView.view.frame = view.frame
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
    
    func getFollowers(for user: User) {
        guard user.following > 0 else {
            presentAlert(title: "Oops, No Followers.", message: "This user has no followers🤷🏽‍♂️.", buttonTitle: "Okay")
            return
        }
        Task {
            do {
                let followers = try await NetworkingManager.shared.getFollowers(for: user.login, page: 1)
                presentFollowSheet(for: .follower, followItems: followers)
            } catch {
                print("There is a error: ", error.localizedDescription)
                if let ghError = error as? GHSearchError {
                    presentAlert(title: "Something went wrong", message: ghError.rawValue, buttonTitle: "OK") {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    func getFollowings(for user: User) {
        guard user.following > 0 else {
            presentAlert(title: "Oops, No Followings!!!", message: "This user has no followings🤷🏽‍♂️.", buttonTitle: "Okay")
            return
        }
        
        Task {
            do {
                let followings = try await NetworkingManager.shared.getFollowings(for: user.login, page: 1)
                presentFollowSheet(for: .following, followItems: followings)
            } catch {
                print("There is a error: ", error.localizedDescription)
                if let ghError = error as? GHSearchError {
                    presentAlert(title: "Something went wrong", message: ghError.rawValue, buttonTitle: "OK")
                }
            }
        }
        
    }
    
    func presentFollowSheet(for followType: FollowActivityType, followItems: [Follower]) {
        
        guard !followItems.isEmpty else {
            presentAlert(title: "Ooops, No \(followType.title)!!!", message: "This user has no \(followType.title)🤷🏽‍♂️.", buttonTitle: "Alright😟")
            return
        }
        let listView =  SampleListView(username: user.login, title: followType.title, followers: followItems, delegate: self)
        let listVC = UIHostingController(rootView: listView)

        present(listVC, animated: true)
        
    }
    
    func getUserInfo(username: String) {
        
        startLoadingActivityView()
        
        Task {
            do {
                let user = try await NetworkingManager.shared.getUserInfo(for: username)
                self.user = user
                configureUserProfileView(user: user)
                stopLoadingActivityView()
                
            } catch {
                if let ghError = error as? GHSearchError {
                    presentAlert(title: "Something went wrong", message: ghError.rawValue, buttonTitle: "OK") {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    presentUnknownError()
                }
                stopLoadingActivityView()
            }
        }
    }
    
//    func configureCollectionView() {
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
//        view.addSubview(collectionView)
//        collectionView.delegate = self
//        collectionView.backgroundColor = .systemBackground
//        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: String(describing: FollowerCell.self))
//    }
    
//    func configureSearchController() {
//        let searchController = UISearchController()
//        searchController.searchResultsUpdater = self
//        searchController.searchBar.placeholder = "Search for a username"
//        searchController.obscuresBackgroundDuringPresentation = false
//        navigationItem.searchController = searchController
//    }
    
//    func getFollowers(username: String, page: Int) {
//        showLoadingView()
//        isLoadingMoreFollowers = true
//
//        Task {
//            do {
//                let followers = try await NetworkingManager.shared.getFollowers(for: username, page: page)
//                updateUI(with: followers)
//                dismissLoadingView()
//            } catch {
//                if let gfError = error as? GHSearchError {
//                    self.presentAlert(title: "An error occured",
//                                      message: gfError.rawValue,
//                                      buttonTitle: "Ok") {
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                } else {
//                    presentDefaultError()
//                }
//
//                dismissLoadingView()
//            }
//
////            guard let followers = try? await NetworkManager.shared.getFollowers(for: username, page: page) else {
////                presentDefaultError()
////                dismissLoadingView()
////                return
////            }
////
////            updateUI(with: followers)
////            dismissLoadingView()
//        }
//
////        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
////            guard let self = self else { return }
////            self.dismissLoadingView()
////
////            switch result {
////
////            case .success(let followers):
////                self.updateUI(with: followers)
////
////            case .failure(let error):
////                self.presentGFAlertOnMainThread(title: "Bad Stuff Happened", message: error.rawValue, buttonTitle: "Ok") {
////                    self.navigationController?.popViewController(animated: true)
////                }
////            }
////
////            self.isLoadingMoreFollowers = false
////        }
//    }
    
//    func updateUI(with followers: [Follower]) {
//        if followers.count < 100 { self.hasMoreFollowers = false }
//        self.followers.append(contentsOf: followers)
//
//        if self.followers.isEmpty {
//            let message = "This user doesn't have any followers. Go follow them 😀."
////            DispatchQueue.main.async { self.showEmptyStateView(with: message, in: self.view) }
//            return
//        }
//
//        self.updateData(on: self.followers)
//    }
    
//    func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UICollectionViewCell.self), for: indexPath) as! UICollectionViewCell
////            cell.set(follower: follower)
//            return cell
//        })
//    }
    
//    func updateData(on followers: [Follower]) {
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
//        snapshot.appendSections([.main])
//        snapshot.appendItems(followers)
//
//        DispatchQueue.main.async {
//            self.dataSource.apply(snapshot, animatingDifferences: true)
//        }
//    }
    
    @objc func addButtonTapped() {
        addUserToBookmarks(user: user)
    }
    
    func addUserToBookmarks(user: User) {
        PersistenceManager.updateBookmarks(with: user, actionType: .add) { [self] error in
            
            DispatchQueue.main.async {
                guard let error = error else {
                    presentAlert(title: "Success!", message: "This user has successfully bookmarked.", buttonTitle: "Perfect!")
                    return
                }
                presentAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
}

extension UserProfileViewController: UICollectionViewDelegate {
    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//        let height = scrollView.frame.size.height
//
//        if offsetY > contentHeight - height {
//            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
//            page += 1
//            getFollowers(username: username, page: page)
//        }
//    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let activeArray = isSearching ? filteredFollowers : followers
//        let follower = activeArray[indexPath.item]
//
//        let userInfoVC = UserInfoVC()
//        userInfoVC.username = follower.login
//        userInfoVC.delegate = self
//        let navController = UINavigationController(rootViewController: userInfoVC)
//        present(navController, animated: true)
//    }
}

//extension UserProfileViewController: UISearchResultsUpdating {
//
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
//            isSearching = false
//            filteredFollowers.removeAll()
//            updateData(on: followers)
//            return
//        }
//
//        isSearching = true
//        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
//        updateData(on: filteredFollowers)
//    }
//}

extension UserProfileViewController: UserInfoVCDelegate {
    func didRequestShowProfile(for username: String) {
        dismiss(animated: true)
        getUserInfo(username: username)
    }
    
    func didRequestFollowers(for username: String, page: Int) {
        
    }
    
//
    func didRequestFollowers(for username: String) {
//        self.username = username
//        title = username
//        page = 1
//
//        followers.removeAll()
//        filteredFollowers.removeAll()
//        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
//        getFollowers(username: username, page: page)
    }
}
