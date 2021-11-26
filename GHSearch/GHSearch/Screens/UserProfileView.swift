//
//  UserProfileView.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 26/11/2021.
//

import SwiftUI

struct UserProfileView: View {
    var user: User
    var onRequestFollowers: (User) -> Void
    var onRequestFollowing: (User) -> Void
    
    @State private var alertItem: GHAlertItem?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    AsyncImage(url: URL(string: user.avatarUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 90, height: 90)
                                .background(Material.regular)
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90, height: 90)
                        case .failure:
                            Image(uiImage: GHImages.imagePlaceholder!)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading) {
                        
                        Text(user.login)
                            .font(.system(size: 30, weight: .bold))
                            .minimumScaleFactor(0.85)
                        Spacer()
                        Text(user.name ?? "")
                            .font(.system(size: 16, weight: .medium))
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
                    Label(user.location ?? "No Location Provided", systemImage: "mappin.and.ellipse")
                    
                    Text(user.bio ?? "No bio available.")
                        .font(.system(.body))
                        .minimumScaleFactor(0.75)
                        .lineLimit(3)
                        .padding(.vertical, 10)
                }
                .foregroundColor(.secondary)
                
                
                HStack {
                    Label("\(user.publicRepos) Public Repos", systemImage:  "folder.fill")
                        .font(.callout.weight(.bold))
                        .font(.callout.weight(.bold))
                        .padding(10)
                        .background(.thinMaterial)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Label("\(user.publicGists) Public Gists", systemImage: "list.bullet.rectangle")
                        .font(.callout.weight(.bold))
                        .padding(10)
                        .background(.thinMaterial)
                        .cornerRadius(8)
                    
                }
                .foregroundColor(.accentColor)
                .minimumScaleFactor(0.9)
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
        }
        .alert(item: $alertItem) { alertItem in
            Alert(title: Text(alertItem.title),
                  message: alertItem.message == nil ? nil : Text(alertItem.message!),
                  dismissButton: .destructive(Text("Got it!")))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("Title")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    bookmarkUser()
                }
                .font(.body.bold())
            }
        }
    }
    
    var followersSection: some View {
        InfoSectionView("\(user.followers) Followers",
                        btnTitle: "Get Followers",
                        btnIcon: "suit.heart") { }
    }
    
    var followingsSectiton: some View {
        InfoSectionView("\(user.following) Following",
                        btnTitle: "Get Following",
                        btnIcon: "person.2",
                        tint: .green) { }
    }
}

extension UserProfileView {
    private func bookmarkUser() {
        guard let error = PersistenceManager.save(user: user) else { return }
        alertItem = GHAlertItem(message: error.rawValue)
        
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(user: .example,
                        onRequestFollowers: { _ in },
                        onRequestFollowing: { _ in })
        //                    .preferredColorScheme(.dark)
    }
}


struct InfoSectionView: View {
    init(_ title: String, btnTitle: String, btnIcon: String, tint: Color = .accentColor, action: @escaping () -> Void) {
        self.title = title
        self.btnTitle = btnTitle
        self.btnIcon = btnIcon
        self.tint = tint
        self.action = action
    }
    
    private let title: String
    private let btnTitle: String
    private let btnIcon: String
    private var tint: Color
    private var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.title.bold())
            
            Button(action: action) {
                Label(btnTitle, systemImage: btnIcon)
                    .foregroundColor(tint)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(tint.opacity(0.2))
                    .cornerRadius(10)
            }
            
            
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(15)
    }
}
