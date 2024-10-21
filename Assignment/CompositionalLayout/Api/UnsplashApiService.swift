//
//  UnsplashApiService.swift
//  CompositionalLayout
//
//  Created by Ved Prakash Mishra on 18/10/24.
//

import Foundation

class UnsplashAPIService {
    
    private let accessKey = "LMaUc7mISezpdEIku6KU_WQp3IkndRig4FdBu0i-mQc"
    private let baseUrl = "https://api.unsplash.com"
    
    // Unified fetch function for both initial fetch and search
    private func buildUrlString(endpoint: String, queryItems: [String: String]) -> String {
        var urlString = "\(baseUrl)\(endpoint)?client_id=\(accessKey)"
        for (key, value) in queryItems {
            urlString += "&\(key)=\(value)"
        }
        return urlString
    }
    
    func fetchImages(page: Int, perPage: Int, completion: @escaping (Result<[UnsplashImage], Error>) -> Void) {
        let urlString = buildUrlString(endpoint: "/photos", queryItems: [
            "page": "\(page)",
            "per_page": "\(perPage)"
        ])
        fetchData(urlString: urlString, completion: completion)
    }
    
    func searchImages(query: String, page: Int, perPage: Int, completion: @escaping (Result<[UnsplashImage], Error>) -> Void) {
        // URL-encode the query string to handle spaces or special characters
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = buildUrlString(endpoint: "/search/photos", queryItems: [
            "query": encodedQuery,
            "page": "\(page)",
            "per_page": "\(perPage)"
        ])
        
        print("Search URL: \(urlString)") // Log the URL for debugging
        
        fetchData(urlString: urlString) { (result: Result<UnsplashSearchResult, Error>) in
            switch result {
            case .success(let searchResult):
                print("Results found: \(searchResult.results.count)") // Log number of results
                completion(.success(searchResult.results))
            case .failure(let error):
                print("Error fetching search results: \(error.localizedDescription)") // Log the error
                completion(.failure(error))
            }
        }
    }

    
    private func fetchData<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

struct UnsplashSearchResult: Decodable {
    let results: [UnsplashImage]
}

