//
//  FollowRowView.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 29/11/2021.
//

import SwiftUI

//class FollowerCell: UITableViewCell {
//    var followerView = FollowRowView(follower: .init(login: "John", avatarUrl: "asfsaf", htmlUrl: "asfasf"), showProfile: { _ in })
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        configure()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func set(follower: Follower, showProfile: @escaping (Follower) -> Void) {
////        avatarImageView.image = GHImages.imagePlaceholder
////        avatarImageView.downloadImage(fromURL: follower.avatarUrl)
////        usernameLabel.text = follower.login
//
////        followerView = FollowRowView(follower: follower, showProfile: showProfile)
//    }
//
//    private func configureLabel( _ label: UILabel) {
//        label.textAlignment = .left
//        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
//        label.textColor = .label
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.9
//        label.lineBreakMode = .byTruncatingTail
//        label.translatesAutoresizingMaskIntoConstraints = false
//    }
//    private func configure() {
//
////        configureLabel(usernameLabel)
////        let swiftUIView = FollowRowView()
//
//        let followerView = UIHostingController(rootView: followerView.frame(width: 300, height: 70))
//
//
//        print(contentView)
//
//
//
////        contentView.addSubviews(avatarImageView, usernameLabel)
////        accessoryType = .disclosureIndicator
////        let padding: CGFloat = 12
////
//        NSLayoutConstraint.activate([
//            followerView.view.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
//            followerView.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10),
//            followerView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//            followerView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10)
//
////            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
////            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
////            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
////            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
////
////            usernameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
////            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 20),
////            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
////            usernameLabel.heightAnchor.constraint(equalToConstant: 38)
//        ])
//    }
//}
//
//
struct FollowRowView: View {
    let follower: Follower
    var showProfile: (Follower) -> Void

    var body: some View {
        HStack {
            GHAvatarView(url: follower.avatarUrl, size: CGSize(width: 70, height: 70))
            VStack(alignment: .leading, spacing: 5) {
                Text(follower.login)
                    .font(.title3.weight(.medium))

                HStack {
                    Button(action: { showProfile(follower) }) {
                        Text("View Profile")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)

                    Spacer()

                    if let githubLink = URL(string: follower.htmlUrl) {
                        Link(destination: githubLink) {
                            HStack(spacing: 3) {
                                Image(systemName: "link")
                                Text("View on GitHub")
                            } .font(.caption)
                        }
                    }
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.9)

        }
        .padding(.horizontal, 10)
    }
    
}
class FollowerCell: UITableViewCell {
    
    let avatarImageView = GHAvatarImageView(frame: .zero)
    let usernameLabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(user: Follower) {
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
