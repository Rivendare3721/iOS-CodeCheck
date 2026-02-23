//
//  iOSEngineerCodeCheckTests.swift
//  iOSEngineerCodeCheckTests
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import XCTest
@testable import iOSEngineerCodeCheck

// MARK: - Mock Service
class MockGitHubService: GitHubServiceProtocol {
    var result: Result<[Repository], Error>?
    var lastQuery: String?
    
    func fetchRepositories(with query: String, completion: @escaping (Result<[Repository], Error>) -> Void) -> URLSessionTask? {
        lastQuery = query
        if let result = result {
            completion(result)
        }
        return nil
    }
}

// MARK: - ViewModel Tests
class RepositorySearchViewModelTests: XCTestCase {
    var viewModel: RepositorySearchViewModel!
    var mockService: MockGitHubService!
    
    override func setUp() {
        super.setUp()
        mockService = MockGitHubService()
        // 依存性の注入（DI）：ViewModelにMockを注入
        viewModel = RepositorySearchViewModel(service: mockService)
    }
    
    /// 検索が正常に成功するケースのテスト
    func testSearch_Success() {
        // テストデータの準備（Mockデータ）
        let mockRepo = Repository(
            fullName: "apple/swift",
            language: "Swift",
            stargazersCount: 100,
            watchersCount: 100,
            forksCount: 50,
            openIssuesCount: 10,
            owner: Owner(avatarUrl: "https://example.com")
        )
        mockService.result = .success([mockRepo])
        
        // 非同期処理を待機するためのExpectationを作成
        let expectation = self.expectation(description: "データ更新のコールバック待機")
        
        viewModel.onDataUpdated = {
            expectation.fulfill()
        }
        
        // 検索処理の実行
        viewModel.search(query: "swift")
        
        // 非同期処理の完了を待機（タイムアウトは1秒に設定）
        wait(for: [expectation], timeout: 1.0)
        
        // 実行結果の検証
        XCTAssertEqual(viewModel.repositories.count, 1)
        XCTAssertEqual(viewModel.repositories.first?.fullName, "apple/swift")
        XCTAssertEqual(mockService.lastQuery, "swift")
    }
    
    /// 検索が失敗するケース（エラー発生時）のテスト
    func testSearch_Failure() {
        // ネットワークエラーのシミュレート
        let mockError = NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network Error"])
        mockService.result = .failure(mockError)
        
        let expectation = self.expectation(description: "エラー通知のコールバック待機")
        
        viewModel.onErrorOccurred = { message in
            XCTAssertEqual(message, "Network Error")
            expectation.fulfill()
        }
        
        viewModel.search(query: "invalid")
        
        wait(for: [expectation], timeout: 1.0)
    }
}
