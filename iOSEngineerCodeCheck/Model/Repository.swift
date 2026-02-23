//
//  Model.swift
//  iOSEngineerCodeCheck
//
//  Created by Yang on 2026/02/19.
//  Copyright © 2026 YUMEMI Inc. All rights reserved.
//

struct GitHubSearchResponse: Codable {
    let items: [Repository]
}

struct Repository: Codable {
    let fullName: String
    let language: String?
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let owner: Owner
}

struct Owner: Codable {
    let avatarUrl: String
}
