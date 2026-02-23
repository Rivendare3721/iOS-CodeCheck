//
//  GithubService.swift
//  iOSEngineerCodeCheck
//
//  Created by Yang on 2026/02/19.
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import Foundation

protocol GitHubServiceProtocol {
    func fetchRepositories(with query: String, completion: @escaping (Result<[Repository], Error>) -> Void) -> URLSessionTask?
}

class GitHubService: GitHubServiceProtocol {
    func fetchRepositories(with query: String, completion: @escaping (Result<[Repository], Error>) -> Void) -> URLSessionTask? {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.github.com/search/repositories?q=\(encoded)") else {
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let res = try decoder.decode(GitHubSearchResponse.self, from: data)
                completion(.success(res.items))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
        return task
    }
}
