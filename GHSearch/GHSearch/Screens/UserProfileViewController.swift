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
    func didRequestShowProfile(for username: String)
}

enum FollowActivityType {
    case followers, followings
    var title: String {
        switch self {
        case .followers:
            return "Followers"
        case .followings:
            return "Followings"
        }
    }
}

class UserProfileViewController: DataFetchingActivityVC {
    var userViewModel: GHUserViewModel! // = GHUserViewModel()
    
    private let disposeBag = DisposeBag()
    
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
        userViewModel.followType = .followers
        presentFollowSheet()
    }
    
    func getFollowings(for user: User) {
        guard user.following > 0 else {
            presentAlert(title: "Oops, No Followings!!!", message: "This user does not follow anyone🤷🏽‍♂️.", buttonTitle: "Okay")
            return
        }
        userViewModel.followType = .followings
        presentFollowSheet()
    }
    
    func presentFollowSheet() {
        let listVC = FollowActivityTableViewController()
        listVC.viewModel = userViewModel
        listVC.modalPresentationStyle = .fullScreen
        present(UINavigationController(rootViewController: listVC), animated: true)
        
    }
    
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

extension UserProfileViewController: UserInfoVCDelegate {
    func didRequestShowProfile(for username: String) {
        dismiss(animated: true)
        userViewModel.getUserInfo(for: username)
    }
}
