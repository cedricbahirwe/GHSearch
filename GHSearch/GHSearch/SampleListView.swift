//
//  SampleListView.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import SwiftUI

struct SampleListView: View {
    let title: String
    var followers: [Follower]
    var onShowProfile: (Follower) -> Void
    
    var body: some View {
        NavigationView {
            List {
                FollowRowView(follower: Follower(login: "cedricbahirwe", avatarUrl: "", htmlUrl: "https://github.com/cedricbahirwe")) { _ in }
                
                ForEach(followers) { follower in
                    FollowRowView(follower: follower, showProfile: onShowProfile)
                }
            }
            .navigationBarTitle(title)
        }
        .navigationViewStyle(StackNavigationViewStyle())
       
    }
}

struct SampleListView_Previews: PreviewProvider {
    static var previews: some View {
        SampleListView(title: "Follows", followers: []) { _ in }
    }
}

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
    }
}
