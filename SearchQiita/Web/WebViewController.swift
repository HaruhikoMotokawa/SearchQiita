//
//  WebViewController.swift
//  SearchQiita
//
//  Created by 本川晴彦 on 2023/07/31.
//

import UIKit
import WebKit
/// ウェブビュー
final class WebViewController: UIViewController {
    /// 指定されたURLを表示する
    @IBOutlet private weak var webView: WKWebView!
    /// 記事のデータモデル
    private var qiitaItemModel: QiitaItemModel?
    // 処理が多くないのでそのまま直接定義
    override func viewDidLoad() {
        super.viewDidLoad()
        guard
            let qiitaItemModel = qiitaItemModel,
            let url = URL(string: qiitaItemModel.urlStr) else {
            return
        }
        //受け渡されたモデルのURLを表示する
        webView.load(URLRequest(url: url))
    }

    /// 表示するモデルを受け渡すメソッド
    internal func configure(qiitaItemModel: QiitaItemModel) {
        self.qiitaItemModel = qiitaItemModel
    }
}
