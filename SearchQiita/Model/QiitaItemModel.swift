//
//  QiitaItemModel.swift
//  SearchQiita
//
//  Created by 本川晴彦 on 2023/07/26.
//

import Foundation
// 取得したQiitaのデータを配列にする
// titleプロパティは、Qiita APIから取得したJSONデータのtitleキーに対応する値をマッピングするためのプロパティで記事のタイトルを表します
// urlStrはQiita APIから取得したJSONデータのurlキーに対応する値をマッピングするためのプロパティで記事のurlを表すが、このままでは使えない
// urlプロパティはurlStrを引数にとってURL型に変換したもの
struct QiitaItemModel: Codable {
    // Swiftでのプロパティ名
    var urlStr: String
    var title: String
    var user: QiitaUserModel

    // JSONデータのキー名をSwiftの変数名にマッピングする
    enum CodingKeys: String, CodingKey {
        case urlStr = "url"
        case title
        case user
    }

    // Qiita APIから取得したJSONデータのurlというキーに対応する値をSwiftのURL型に変換する
    // URL.init(string: urlStr)は、urlStrを引数に取り、URL型のオブジェクトを返す
    // urlというコンピューテッドプロパティに定義することで
    // JSONデータのurlキーに対応する値をSwiftのURL型に変換する
    // 今回はsetterは必要ないので省略
    var url: URL? { URL(string: urlStr)}

    var imageUrl: URL? { URL(string: user.profileImageUrlStr) }

}

struct QiitaUserModel: Codable {
    var id: String
    var name: String
    var profileImageUrlStr: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        /*
        QiitaAPIのjsonDecoderで初期設定で
         スネークケースからキャメルケースに変換する設定
         してあるので、ここにはアンスコいらない
         正式には「profile_image_url」
         */
        case profileImageUrlStr = "profileImageUrl"
    }
}

