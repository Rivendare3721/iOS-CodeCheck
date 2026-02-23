//
//  ViewController.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class ViewController: UITableViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // ビジネスロジックを担当するViewModel
    private let viewModel = RepositorySearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        
        // ユーザーに検索を促すプレースホルダーを設定
        searchBar.placeholder = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
    }
    
    // MARK: - ViewModelの状態変化を検知してUIを更新するためのバインディング設定
    private func setupBindings() {
        // データが更新されたらテーブルビューをリロードする
        viewModel.onDataUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        
        // エラー発生時の処理
        viewModel.onErrorOccurred = { [weak self] message in
            print("Error: \(message)")
        }
    }
    
    // MARK: - 画面遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 惊き最小の原則
        guard segue.identifier == "Detail",
              let detailVC = segue.destination as? DetailViewController,
              let repo = sender as? Repository else { return }
        detailVC.repository = repo
    }
}

// MARK: - UISearchBarDelegate
// インターフェイス分離の原則
extension ViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.search(query: searchBar.text)
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSource
// インターフェイス分離の原則
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // メモリリーク防止
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if let repo = viewModel.repository(at: indexPath.row) {
            cell.textLabel?.text = repo.fullName
            cell.detailTextLabel?.text = repo.language ?? "N/A"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let repo = viewModel.repository(at: indexPath.row) {
            performSegue(withIdentifier: "Detail", sender: repo)
        }
    }
}
