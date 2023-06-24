//
//  Movie.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import Foundation

// MARK: - Welcome
struct MovieData: Codable {
    let page: Int
    let results: [Result]

    enum CodingKeys: String, CodingKey {
        case page
        case results
    }
}

// MARK: - Result
struct Result: Codable {
    let backdropPath: String?
    let id: Int
    let title: String?
    let originalLanguage: String
    let originalTitle: String?
    let overview: String
    var posterPath: String?
    var mediaType: MediaType?
    let genreIDS: [Int]?
    let releaseDate: String?
    let voteAverage: Double
    let name: String?
    let originalName: String?
    let firstAirDate: String?
    let originCountry: [String]?
    
    var nameTitle: String {
        return title ?? name ?? ""
    }
    var origTitle: String {
        return originalTitle ?? originalName ?? ""
    }
    var airReleaseDate: String {
        return releaseDate ?? firstAirDate ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case id
        case title
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case mediaType = "media_type"
        case genreIDS = "genre_ids"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case name
        case originalName = "original_name"
        case firstAirDate = "first_air_date"
        case originCountry = "origin_country"
    }
}

enum MediaType: String, Codable {
    case movie = "movie"
    case tv = "tv"
}
