//
//  GithubService.swift
//  iOSEngineerCodeCheck
//
//  Created by Yang on 2026/02/19.
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodeError
}

class GitHubService {
    // CQS原則
    func searchRepositories(with query: String, completion: @escaping (Result<[Repository], APIError>) -> Void) -> URLSessionTask? {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.github.com/search/repositories?q=\(encodedQuery)") else {
            completion(.failure(.invalidURL))
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase // DRY原則
                let response = try decoder.decode(GitHubSearchResponse.self, from: data)
                completion(.success(response.items))
            } catch {
                completion(.failure(.decodeError))
            }
        }
        task.resume()
        return task
    }
}
