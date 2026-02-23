//
//  ViewController2.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var issuesLabel: UILabel!
    
    var repository: Repository?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIテスト用の識別子を設定する
        imageView.accessibilityIdentifier = "repository_avatar_image"
        
        setupUI()
        setupNavigationBar()
        loadAvatarImage()
    }
    
    // MARK: - UI初期化
    private func setupUI() {
        // 惊き最小の原則
        guard let repo = repository else { return }
        
        // DRY原則
        titleLabel.text = repo.fullName
        languageLabel.text = "Written in \(repo.language ?? "Unknown")"
        starsLabel.text = "\(repo.stargazersCount) stars"
        watchersLabel.text = "\(repo.watchersCount) watchers"
        forksLabel.text = "\(repo.forksCount) forks"
        issuesLabel.text = "\(repo.openIssuesCount) open issues"
    }
    
    private func setupNavigationBar() {
        // ナビゲーションバーの色を改修する
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        // ナビゲーションバーの右側にブラウザ起動ボタンを追加
        let browserButton = UIBarButtonItem(
            image: UIImage(systemName: "safari"),
            style: .plain,
            target: self,
            action: #selector(openInBrowser)
        )
        navigationItem.rightBarButtonItem = browserButton
    }
    
    @objc private func openInBrowser() {
        // 💡 驚き最小の原則：URLが正しいか確認してから開く
        guard let urlString = repository?.htmlUrl,
              let url = URL(string: urlString) else {
            return
        }
        
        // SFSafariViewControllerを使用
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    // MARK: - アバター画像を非同期で読み込む
    private func loadAvatarImage() {
        guard let avatarURLString = repository?.owner.avatarUrl,
              let url = URL(string: avatarURLString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            if let error = error {
                print("Image load error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }.resume()
    }
}
