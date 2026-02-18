//
//  ViewController2.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var issuesLabel: UILabel!
    
    var repositoryData: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadAvatarImage()
    }
    
    // MARK: - UI初期化
    private func setupUI() {
        guard let repo = repositoryData else { return }
        
        titleLabel.text = repo["full_name"] as? String ?? "N/A"
        languageLabel.text = "Written in \(repo["language"] as? String ?? "Unknown")"
        starsLabel.text = "\(repo["stargazers_count"] as? Int ?? 0) stars"
        watchersLabel.text = "\(repo["watchers_count"] as? Int ?? 0) watchers"
        forksLabel.text = "\(repo["forks_count"] as? Int ?? 0) forks"
        issuesLabel.text = "\(repo["open_issues_count"] as? Int ?? 0) open issues"
    }
    
    private func loadAvatarImage() {
        guard let repo = repositoryData,
              let owner = repo["owner"] as? [String: Any],
              let avatarURLString = owner["avatar_url"] as? String,
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
