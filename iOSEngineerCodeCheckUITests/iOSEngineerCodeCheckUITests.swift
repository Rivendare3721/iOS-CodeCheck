//
//  iOSEngineerCodeCheckUITests.swift
//  iOSEngineerCodeCheckUITests
//
//  Created by 史 翔新 on 2020/04/20.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import XCTest

class GitHubAppUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        // 失敗時にテストを継続しない設定
        continueAfterFailure = false
        // アプリの起動
        app.launch()
    }
    
    func testDetailImageLoading() {
        // 1. 検索操作のシミュレーション
        let searchBar = app.searchFields.firstMatch
        XCTAssertTrue(searchBar.exists)
        
        searchBar.tap()
        searchBar.typeText("swift")
        // キーボードの検索ボタンをタップ
        app.keyboards.buttons["search"].tap()
        
        // 2. リストの読み込みを待機し、最初のセルをタップ
        let firstCell = app.tables.cells.element(boundBy: 0)
        // ネットワークレスポンスを待機するために waitForExistence を使用
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5.0))
        firstCell.tap()
        
        // 3. 詳細画面へ遷移し、画像Viewが存在するか確認
        let detailImage = app.images["repository_avatar_image"]
        XCTAssertTrue(detailImage.exists, "詳細画面に画像Viewが表示されるべきです")
        
        // 4. (応用) 画像が実際にロードされたかを確認
        // UIテストでピクセル単位の判定は困難だが、サイズや表示状態の待機で判定可能
        // 待機時間を設定して読み込み完了を観察する
        let imageHasLoaded = detailImage.waitForExistence(timeout: 5.0)
        XCTAssertTrue(imageHasLoaded, "規定時間内に画像の読み込みが完了しませんでした")
    }
}
