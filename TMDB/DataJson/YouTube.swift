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
    let iso639_1: String
    let iso3166_1: String
    let name: String
    let key: String
    let site: String
    let size: Int
    let type: String
    let official: Bool
    let publishedAt: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case name, key, site, size, type, official
        case publishedAt = "published_at"
        case id
    }
}
