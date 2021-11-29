//
//  UserInfoSectionView.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import SwiftUI

struct UserInfoSectionView: View {
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
