//
//  Model.swift
//  CompositionalLayout
//
//  Created by Ved Prakash Mishra on 18/10/24.
//

import Foundation

struct UnsplashImage: Decodable {
    let id: String
    let urls: URLS
}

struct URLS: Decodable {
    let small: String
}

