//
//  UserProfileViewController.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 26/11/2021.
//

import UIKit
import SwiftUI
import RxSwift

protocol UserInfoVCDelegate: AnyObject {
    func didRequestFollowers(for username: String, page: Int)
    func didRequestFollowing(for username: String, page: Int)
    
    func didRequestShowProfile(for username: String)
}

class UserProfileViewController: DataFetchingActivityVC {
    var userViewModel: GHUserViewModel! // = GHUserViewModel()
    
    private let disposeBag = DisposeBag()
    
    private var selectUser = ReadOnce<User>(nil)
    
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
//    var user: User!
    
    
//    var page = 1
//    var hasMoreFollowers = true
//    var isSearching = false
//    var isLoadingMoreFollowers = false
//
//    var collectionView: UICollectionView!
//    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!

//    var userProfileView: UserProfileView!
    
    init(username: String, userViewModel: GHUserViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.username = username
        self.userViewModel = userViewModel
        title = username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        bindViewModel()
        userViewModel.getUserInfo(for: username)
//        getUserInfo(username: username)
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
        
        print(view.subviews.count)
    }
    
    func getFollowers(for user: User) {
        guard user.followers > 0 else {
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
            presentAlert(title: "Oops, No Followings!!!", message: "This user does not follow anyone🤷🏽‍♂️.", buttonTitle: "Okay")
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
            presentAlert(title: "Oops, No \(followType.title)!!!", message: "This user has no \(followType.title)🤷🏽‍♂️.", buttonTitle: "Alright😟")
            return
        }
        let listView =  SampleListView(username: userViewModel.selectedUser.value!.login, title: followType.title, followers: followItems, delegate: self)
        let listVC = UIHostingController(rootView: listView)

        present(listVC, animated: true)
        
    }
    
//    func getUserInfo(username: String) {
//
//        startLoadingActivityView()
//
//        Task {
//            do {
//                let user = try await NetworkingManager.shared.getUserInfo(for: username)
//                self.user = user
//                configureUserProfileView(user: user)
//                stopLoadingActivityView()
//
//            } catch {
//                if let ghError = error as? GHSearchError {
//                    presentAlert(title: "Something went wrong", message: ghError.rawValue, buttonTitle: "OK") {
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                } else {
//                    presentUnknownError()
//                }
//                stopLoadingActivityView()
//            }
//        }
//    }
    
    func bindViewModel() {
        userViewModel.selectedUser
            .compactMap { $0 }
            .map({ [weak self] in
                self?.configureUserProfileView(user: $0)
            })
            .subscribe()
            .disposed(by: disposeBag)

        userViewModel
            .onShowError
            .map { [weak self] in self?.presentAlert(title: "Oops!", message: $0.rawValue, buttonTitle: "OK") }
            .subscribe()
            .disposed(by: disposeBag)

        userViewModel
            .onShowLoadingView
            .map { [weak self] isVisible in
                print("Pbulished", isVisible)
                if isVisible {
                    self?.startLoadingActivityView()
                } else {
                    self?.stopLoadingActivityView()
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @objc func addButtonTapped() {
        addUserToBookmarks(user: userViewModel.selectedUser.value!)
    }
    
    func addUserToBookmarks(user: User) {
        PersistenceManager.updateBookmarks(with: user, actionType: .add) { [self] error in
            
            DispatchQueue.main.async {
                guard let error = error else {
                    presentAlert(title: "Success!", message: "This user has successfully been bookmarked.", buttonTitle: "Perfect!")
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



extension UserProfileViewController: UserInfoVCDelegate {
    func didRequestFollowing(for username: String, page: Int) {
        print("didRequestFollowing")
    }
    
    func didRequestShowProfile(for username: String) {
        dismiss(animated: true)
        userViewModel.getUserInfo(for: username)
//        getUserInfo(username: username)
    }
    
    func didRequestFollowers(for username: String, page: Int) {
        printContent("didRequestFollowers")
    }
    
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
