//
//  YouTube.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 17.06.2023.
//

import Foundation

// MARK: - VideoYouTube
struct VideoYouTube: Codable {
    let id: Int
    let results: [VideData]
}

// MARK: - VideData
struct VideData: Codable {

    let name: String
    let key: String
    let type: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case key, type, name
        case id
    }
}
