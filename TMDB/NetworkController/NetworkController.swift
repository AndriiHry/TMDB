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
    var typeVideo: String = "movie"
    var query: String = ""
    var pageLoaded: Int = 1
    
    //MARK: - load main data from url
    func loadPage(page: Int = 1) async throws -> [Result] {
        guard let url = URL(string: "\(Constants.starttUrl)trending/\(typeVideo)/day?api_key=\(Constants.api)&page=\(page)")
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
    
    //MARK: - search data from searchTcontroller in navigation
    func searchPageFor(typeVideo: String) async throws -> [Result] {
        guard let url = URL(string: "\(Constants.starttUrl)search/\(typeVideo)?query=\(query)&api_key=\(Constants.api)")
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
    
    //MARK: -  load details from video ID tv or movie
    func loadDetailsWith(id: Int, typeVideo: String) async throws -> DetailsData? {
        guard let url = URL(string: "\(Constants.starttUrl)\(typeVideo)/\(id)?&api_key=\(Constants.api)")
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
    
    //MARK: -load youtube videID from main ID
    func loadVideoDataWith(id: Int, typeVideo: String) async throws -> [VideData] {
        guard let url = URL(string: "\(Constants.starttUrl)\(typeVideo)/\(id)/videos?&api_key=\(Constants.api)")
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
