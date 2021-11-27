//
//  UserProfileView.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 26/11/2021.
//

import SwiftUI

struct UserProfileView: View {
    @State var user: User
    var onRequestFollowers: (User) -> Void
    var onRequestFollowing: (User) -> Void
    
    @State private var alertItem: GHAlertItem?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    GHAvatarView(url: user.avatarUrl)
                    
                    VStack(alignment: .leading) {
                        
                        Text(user.login)
                            .font(.system(size: 30, weight: .bold))
                            .minimumScaleFactor(0.85)
                        Spacer()
                        Text(user.name ?? "")
                            .font(.system(size: 18, weight: .medium))
                            .minimumScaleFactor(0.9)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Member since \(user.createdAt.convertingToMonthYear())")
                            .font(.system(size: 16, weight: .medium))
                            .minimumScaleFactor(0.9)
                            .foregroundColor(.secondary)
                    }
                    .lineLimit(1)
                    
                    Spacer()
                }
                .frame(height: 90, alignment: .top)
                
                VStack(alignment: .leading) {
                    LocationLabel(user.location ?? "No Location Provided")
                    
                    Text(user.bio ?? "No bio available.")
                        .font(.system(.body))
                        .minimumScaleFactor(0.75)
                        .lineLimit(3)
                        .padding(.vertical, 10)
                }
                .foregroundColor(.secondary)
                
                
                HStack {
                    Label("\(user.publicRepos) Public Repos", systemImage:  "folder.fill")
                        .padding(10)
                        .background(.thinMaterial)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Label("\(user.publicGists) Public Gists", systemImage: "list.bullet.rectangle")
                        .padding(10)
                        .background(.thinMaterial)
                        .cornerRadius(8)
                    
                }
                .font(.callout.weight(.semibold))
                .foregroundColor(.accentColor)
                .minimumScaleFactor(0.85)
                .lineLimit(1)
                
                followersSection
                    .padding(.bottom)
                
                followingsSectiton
                
                
                if let githubLink = user.htmlUrl {
                    Link(destination: URL(string: githubLink)!) {
                        Text("View on GitHub")
                            .foregroundStyle(.background)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(.primary)
                    .cornerRadius(10)
                    .padding(.vertical)
                    
                }
            }
            .padding(.horizontal)
//            .redacted(reason:  user.login == User.example.login ? .placeholder : [])
        }
        .alert(item: $alertItem) { alertItem in
            Alert(title: Text(alertItem.title),
                  message: alertItem.message == nil ? nil : Text(alertItem.message!),
                  dismissButton: .destructive(Text("Got it!")))
        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarTitle("Title")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Done") {
//                    bookmarkUser()
//                }
//                .font(.body.bold())
//            }
//        }
    }
    
    var followersSection: some View {
        UserInfoSectionView("\(user.followers) Followers",
                        btnTitle: "Get Followers",
                        btnIcon: "suit.heart", action: {
            onRequestFollowers(user)
        })
    }
    
    var followingsSectiton: some View {
        UserInfoSectionView("\(user.following) Following", btnTitle: "Get Following",
                        btnIcon: "person.2", tint: .green, action: {
            onRequestFollowing(user)
        })
    }
}

extension UserProfileView {
//    private func bookmarkUser() {
//        guard let error = PersistenceManager.save(user: user) else { return }
//        alertItem = GHAlertItem(message: error.rawValue)
//        
//    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(user: .example,
                        onRequestFollowers: { _ in },
                        onRequestFollowing: { _ in })
        //                    .preferredColorScheme(.dark)
    }
}
