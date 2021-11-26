//
//  GHAvatarImageView.swift
//  GHSearch
//
//  Created by Cédric Bahirwe on 26/11/2021.
//

import UIKit
import SwiftUI

class GHAvatarImageView: UIImageView {
    
    let cache = NetworkingManager.shared.cache
    let placeholderImage = GHImages.imagePlaceholder
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func downloadImage(fromURL url: String) {
        Task { image = await NetworkingManager.shared.downloadedImage(from: url) ?? placeholderImage }
    }
}

struct GHAvatarImage: UIViewRepresentable {
    var imageURL: String
    func makeUIView(context: Context) -> UIImageView {
        let imageView = GHAvatarImageView(frame: .zero)
        imageView.downloadImage(fromURL: imageURL)
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
