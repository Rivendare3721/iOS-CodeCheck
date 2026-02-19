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
    
    var repository: Repository?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
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
