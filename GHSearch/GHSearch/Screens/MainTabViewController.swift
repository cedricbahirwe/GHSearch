//
//  MainTabViewController.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 26/11/2021.
//

import UIKit

class MainTabViewController: UITabBarController {
    let userViewModel = GHUserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [createSearchVC(), createFavoritesNC()]
    }
    
    func createSearchVC() -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as! SearchViewController
        searchVC.userViewModel = userViewModel
        searchVC.title = "Search"
        searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        return UINavigationController(rootViewController: searchVC)
    }
    
    func createFavoritesNC() -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bookmarksListVC = storyboard.instantiateViewController(withIdentifier: String(describing: BookmarksTableVC.self)) as! BookmarksTableVC
        bookmarksListVC.userViewModel = userViewModel
        bookmarksListVC.title = "Bookmarks"
        bookmarksListVC.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark.circle"), tag: 1)
        
        return UINavigationController(rootViewController: bookmarksListVC)
    }

}
