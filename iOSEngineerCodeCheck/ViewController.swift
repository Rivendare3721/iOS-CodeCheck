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
    
    private(set) var repositories: [[String: Any]] = []
    private var task: URLSessionTask?
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI() {
        searchBar.placeholder = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 入力内容を安全にアンラップし、URLエンコードを処理する
        guard let searchText = searchBar.text, !searchText.isEmpty,
              let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        let urlString = "https://api.github.com/search/repositories?q=\(encodedText)"
        guard let url = URL(string: urlString) else { return }
        
        // 先ほどの検索タスクをキャンセルする
        task?.cancel()
        
        // [weak self] を使用して、循環参照によるメモリリークを防止する
        task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            // エラー処理
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let items = jsonObject["items"] as? [[String: Any]] {
                    
                    self?.repositories = items
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
            }
        }
        task?.resume()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        task?.cancel()
    }
}

// MARK: - UITableViewDataSource
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // メモリリーク防止
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let repo = repositories[indexPath.row]
        
        cell.textLabel?.text = repo["full_name"] as? String ?? "Unknown"
        cell.detailTextLabel?.text = repo["language"] as? String ?? "N/A"
        cell.tag = indexPath.row
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "Detail", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "Detail",
              let detailVC = segue.destination as? DetailViewController,
              let index = selectedIndex,
              repositories.indices.contains(index)
        else {
            return
        }
        detailVC.repositoryData = repositories[index]
    }
}
