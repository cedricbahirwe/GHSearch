//
//  FollowActivityTableViewController.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import UIKit
import RxSwift

class FollowActivityTableViewController: UIViewController {
    var viewModel: GHUserViewModel!
    private let disposeBag = DisposeBag()
        
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: UITableViewCell.description())
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.refreshControl = refreshControl
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var viewSpinner: UIView = {
            let view = UIView(frame: CGRect(
                                x: 0,
                                y: 0,
                                width: view.frame.size.width,
                                height: 100)
            )
            let spinner = UIActivityIndicatorView()
            spinner.center = view.center
            view.addSubview(spinner)
            spinner.startAnimating()
            return view
        }()
    
    var titles: String {
        let ele = viewModel.followers.value.count
        title  = ele.description
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        layout()
        
        tableViewBind()
        
        viewModel.fetchMoreFollowers.onNext(())
        
        title =  viewModel.followType?.title ?? "XXXXX"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.followers = []
        
    }
    
    @objc func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func layout() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
        ])
    }
    
    private func tableViewBind() {
        viewModel.followers.bind(to: tableView.rx.items) { tableView, _, item in
            let cell = tableView
                .dequeueReusableCell(withIdentifier: UITableViewCell.description())
            cell?.textLabel?.text = item.login
            cell?.selectionStyle = .none
            return cell ?? UITableViewCell()
        }
        .disposed(by: disposeBag)
        
        tableView.rx.didScroll.subscribe { [weak self] _ in
            guard let self = self else { return }
            let offSetY = self.tableView.contentOffset.y
            let contentHeight = self.tableView.contentSize.height
            
            if offSetY > (contentHeight - self.tableView.frame.size.height - 20) {
                self.viewModel.fetchMoreFollowers.onNext(())
            }
        }
        .disposed(by: disposeBag)
        
        viewModel.showFollowersListSpinner.subscribe { [weak self] isShown in
            guard let isAvaliable = isShown.element,
                  let self = self else { return }
            self.tableView.tableFooterView = isAvaliable ? self.viewSpinner : UIView(frame: .zero)
        }
        .disposed(by: disposeBag)
    }
    
    
}


extension FollowActivityTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
