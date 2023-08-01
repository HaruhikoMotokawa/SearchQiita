//
//  QiitaAccessTokenModel.swift
//  SearchQiita
//
//  Created by 本川晴彦 on 2023/07/26.
//

import Foundation

// Qiitaのアクセストークンを配列で受け取るためのモデル
// Codableに準拠することで、JSONEにエンコードしやすくなる
struct QiitaAccessTokenModel: Codable {
    let clientId: String
    let scopes: [String]
    let token: String
}
