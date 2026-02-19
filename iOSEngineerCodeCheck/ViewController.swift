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
    
    private let service = GitHubService()
    private var repositories: [Repository] = []
    private var searchTask: URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI() {
        searchBar.placeholder = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 惊き最小の原則
        guard segue.identifier == "Detail",
              let detailVC = segue.destination as? DetailViewController,
              let repository = sender as? Repository else { return }
        detailVC.repository = repository
    }
}

// MARK: - UISearchBarDelegate
// インターフェイス分離の原則
extension ViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        // 入力内容を安全にアンラップし、URLエンコードを処理する
        guard let text = searchBar.text, !text.isEmpty else { return }
        
        // 先ほどの検索タスクをキャンセルする
        searchTask?.cancel()
        
        // [weak self] を使用して、循環参照によるメモリリークを防止する
        searchTask = service.searchRepositories(with: text) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self?.repositories = items
                    self?.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
// インターフェイス分離の原則
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // メモリリーク防止
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let repo = repositories[indexPath.row]
        cell.textLabel?.text = repo.fullName
        cell.detailTextLabel?.text = repo.language ?? "N/A"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repo = repositories[indexPath.row]
        performSegue(withIdentifier: "Detail", sender: repo)
    }
}
