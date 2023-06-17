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
    let apiKey: String = "7ca2617d325e2e18b7ba1914513ef1f4"
    var typeVideo: String = "movie"
    var query: String = ""
    var pageLoaded: Int = 1
    
    // load main data from url
    func loadPage(page: Int = 1) async throws -> [Result] {
        guard let url = URL(string: "https://api.themoviedb.org/3/trending/\(typeVideo)/day?api_key=\(apiKey)&page=\(page)")
        else
        {
            print("Errore Load URL")
            return []
        }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        let sessionResponse = try await session.data(for: request)
        let moviesResponse = try decoder.decode(MovieData.self, from: sessionResponse.0)
        return moviesResponse.results
    }
    
    func loadNextPage() async throws -> [Result] {
        defer
        {
            pageLoaded += 1
        }
        return try await loadPage(page: pageLoaded)
    }
    
    // search data from searchTcontroller in navigation
    func searchPage(page: Int = 1) async throws -> [Result] {
        guard let url = URL(string: "https://api.themoviedb.org/3/search/\(typeVideo)?query=\(query)&api_key=\(apiKey)")
        else
        {
            print("Errore Search URL")
            return []
        }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        let sessionResponse = try await session.data(for: request)
        let moviesResponse = try decoder.decode(MovieData.self, from: sessionResponse.0)
        return moviesResponse.results
    }
    
    func searcNextPage() async throws -> [Result] {
        defer
        {
            pageLoaded += 1
        }
        return try await searchPage(page: pageLoaded)
    }
    
    // load details from video ID tv or movie
    func loadDetailsFromId(id: Int) async throws -> DetailsData? {
        guard let url = URL(string: "https://api.themoviedb.org/3/\(typeVideo)/\(id)?language=en-US&api_key=\(apiKey)")
        else
        {
            print("Errore detail ID URL")
            return nil
        }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        let sessionResponse = try await session.data(for: request)
        let detailsResponse = try decoder.decode(DetailsData.self, from: sessionResponse.0)
        return detailsResponse
    }
    
    //load youtube videID from main ID
    func loadVideoData(id: Int) async throws -> [VideData] {
        guard let url = URL(string: "https://api.themoviedb.org/3/\(typeVideo)/\(id)/videos?language=en-US&api_key=\(apiKey)")
        else
        {
            print("Errore Load Video Data from ID")
            return []
        }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        let sessionResponse = try await session.data(for: request)
        let moviesResponse = try decoder.decode(VideoYouTube.self, from: sessionResponse.0)
        return moviesResponse.results
    }


}
