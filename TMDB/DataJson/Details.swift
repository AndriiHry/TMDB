//
//  Details.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 14.06.2023.
//

import Foundation

// MARK: - Welcome
struct DetailsData: Codable {
    let genres: [Genre]
    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
    let originCountry: [String]?
    var origCountr: String {
        return productionCountries.first?.name ?? originCountry?.first ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case genres
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case originCountry = "origin_country"

    }
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String
}

// MARK: - ProductionCompany
struct ProductionCompany: Codable {
    let id: Int
    let logoPath: String?
    let name: String
    let originCountry: String

    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}

// MARK: - ProductionCountry
struct ProductionCountry: Codable {
    let iso3166_1, name: String

    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name
    }
}
