//
//  SampleListView.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import SwiftUI
import RxCocoa

struct FollowsListView: View {
    @Environment(\.dismiss)
    private var dismiss
    
    @ObservedObject var userViewModel: GHUserViewModel
    var followType: FollowActivityType
//    let username: String
//   @State var followers: [Follower]
    var delegate: UserInfoVCDelegate!
//    var onShowProfile: (Follower) -> Void
    
    @State private var page: Int = 1
    
    @State private var hasMoreData = true
    @State private var isFetchingMoreData = false
    
    var body: some View {
        NavigationView {
            List {
                
                ForEach(userViewModel.followers.value) { follower in
                    FollowRowView(follower: follower) { follower in
                        delegate.didRequestShowProfile(for: follower.login)
                    }
                }
                
                
                if  hasMoreData, !isFetchingMoreData  {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.3)
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            page += 1
                            requestFollowers()
                            print("Appeared")
//                            delegate.didRequestFollowers(for: <#T##String#>)
                        }
                }
            }
            .navigationBarTitle("\(followType.title) \(userViewModel.followers.value.count)")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body.bold())
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
       
    }
    
    private func requestFollowers() {
        let username = userViewModel.selectedUser.value!.login
        isFetchingMoreData = true
        
        userViewModel.getFollows(of: followType, username: username, page: page)
    }
}

struct SampleListView_Previews: PreviewProvider {
    static var previews: some View {
        FollowsListView(userViewModel: GHUserViewModel(),
                        followType: .followers, delegate: nil)
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
