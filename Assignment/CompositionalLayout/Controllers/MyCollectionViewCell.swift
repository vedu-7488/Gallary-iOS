//
//  UserDetailsCollectionViewCell.swift
//  CompositionalLayout
//
//  Created by Ved Prakash Mishra on 20/10/24.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
    
    func setup(imageUrl: String) {
        cellImageView.loadImage(from: imageUrl)
    }
}

