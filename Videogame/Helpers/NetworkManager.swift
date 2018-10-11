//
//  NetworkManager.swift
//  Videogame
//
//  Created by Raja reddy Poreddy on 10/10/18.
//  Copyright © 2018 Delvelogic. All rights reserved.
//

import UIKit

// Network error ENUM
enum NetworkError: Error {
    case invalidURL
}

/// This class is responsible for handling the server calls
class NetworkManager {
    
    // end point to make server call
    let endpoint = "https://www.giantbomb.com/api/search/?"
    
    // url session task
    var task: URLSessionTask?
    
    // Method to fetch games
    func fetchGames(
        matching query: String?, page: Int,
        onCompletion: @escaping (VideoGameResult) -> Void) {
        
        // completion handler
        func fireErrorCompletion(_ error: Error?) {
            onCompletion(VideoGameResult(videoGames: nil, error: error,
                currentPage: 0, pageCount: 0))
        }
        
        var queryOrEmpty = "game"
        
        if let query = query, !query.isEmpty {
            queryOrEmpty = query
        }
        
        var components = URLComponents(string: endpoint)
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: "dcc02dfa193595af8385326a56adf551b6c9c6f5"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "query", value: queryOrEmpty),
            URLQueryItem(name: "page", value: String(page))
        ]
        
        guard let url = components?.url else {
            fireErrorCompletion(NetworkError.invalidURL)
            return
        }
        
        task?.cancel()
        
        task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            DispatchQueue.main.async {
                
                if let error = error {
                    guard (error as NSError).code != NSURLErrorCancelled else {
                        return
                    }
                    fireErrorCompletion(error)
                    return
                }
                
                guard let data = data else {
                    fireErrorCompletion(error)
                    return
                }
                
                
                do {
                    let result = try JSONDecoder().decode(VideoGameResponse.self, from: data)
                    
                    let headEndResult = result.results.prefix(10)
                    
                    onCompletion(VideoGameResult(videoGames: Array(headEndResult),
                                                  error: nil,
                                                  currentPage: 1,
                                                  pageCount: 1))
                } catch {
                    fireErrorCompletion(error)
                }
            }
        }
        task?.resume()
    }
}
