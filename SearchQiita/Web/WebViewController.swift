//
//  WebViewController.swift
//  SearchQiita
//
//  Created by 本川晴彦 on 2023/07/31.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {

    @IBOutlet private weak var webView: WKWebView!

    private var qiitaItemModel: QiitaItemModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard
            let qiitaItemModel = qiitaItemModel,
            let url = URL(string: qiitaItemModel.urlStr) else {
            return
        }
        webView.load(URLRequest(url: url))

    }

    internal func configure(qiitaItemModel: QiitaItemModel) {
        self.qiitaItemModel = qiitaItemModel
    }
}
