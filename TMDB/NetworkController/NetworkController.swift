//
//  NetworkController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import Foundation

class NetworkController {
    let session = URLSession.shared
    let decoder = JSONDecoder()
    var pageLoaded: Int = 1
    
    func loadData(page: Int = 1, trend: String = "movie") async throws -> [Result] {
        let url = URL(string: "https://api.themoviedb.org/3/trending/\(trend)/day?api_key=7ca2617d325e2e18b7ba1914513ef1f4&page=\(page)")!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy,timeoutInterval: 10.0)
        request.httpMethod = "GET"
        let sessionResponse = try await session.data(for: request)
        let moviesResponse = try decoder.decode(MovieData.self, from: sessionResponse.0)
        return moviesResponse.results
    }
    
    func loadNextPage() async throws -> [Result] {
        defer {
            pageLoaded += 1
        }
        return try await loadData(page: pageLoaded)
    }
}
