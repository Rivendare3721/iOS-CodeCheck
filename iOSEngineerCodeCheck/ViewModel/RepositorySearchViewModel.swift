//
//  RepositorySearchViewModel.swift
//  iOSEngineerCodeCheck
//
//  Created by Yang on 2026/02/23.
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

import Foundation

class RepositorySearchViewModel {
    var onDataUpdated: (() -> Void)?
    var onErrorOccurred: ((String) -> Void)?
    
    private(set) var repositories: [Repository] = []
    private let service: GitHubServiceProtocol
    private var searchTask: URLSessionTask?
    
    init(service: GitHubServiceProtocol = GitHubService()) {
        self.service = service
    }
    
    func search(query: String?) {
        // 入力内容を安全にアンラップし、URLエンコードを処理する
        guard let query = query, !query.isEmpty else { return }
        // 先ほどの検索タスクをキャンセルする
        searchTask?.cancel()
        // [weak self] を使用して、循環参照によるメモリリークを防止する
        searchTask = service.fetchRepositories(with: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.repositories = items
                    self?.onDataUpdated?()
                case .failure(let error):
                    self?.onErrorOccurred?(error.localizedDescription)
                }
            }
        }
    }
    
    func repository(at index: Int) -> Repository? {
        return repositories.indices.contains(index) ? repositories[index] : nil
    }
}
