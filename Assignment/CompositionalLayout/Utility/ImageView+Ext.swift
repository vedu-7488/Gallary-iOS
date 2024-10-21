//
//  ImageView+Ext.swift
//  CompositionalLayout
//
//  Created by Ved Prakash Mishra on 18/10/24.
//

import Foundation

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {

    func loadImage(from urlString: String) {
        self.image = nil

        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }

        guard let url = URL(string: urlString) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }

            DispatchQueue.main.async {
                imageCache.setObject(image, forKey: urlString as NSString)
                self.image = image
            }
        }
        task.resume()
    }
}
