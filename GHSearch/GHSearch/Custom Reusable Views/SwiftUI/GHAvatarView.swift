//
//  GHAvatarView.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 27/11/2021.
//

import SwiftUI

struct GHAvatarView: View {
    let url: String
    var size: CGSize = CGSize(width: 90, height: 90)
    var cornerRadius: CGFloat = 10
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty, .failure:
                Image(uiImage: GHImages.imagePlaceholder!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            @unknown default:
                EmptyView()
            }
        }
        
        .cornerRadius(cornerRadius)
    }
}


struct GHAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        GHAvatarView(url: "")
    }
}
