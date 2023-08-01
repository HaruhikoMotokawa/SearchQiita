
import Foundation
// 拡張を使ってUserDefaultsに独自のプロパティを定義することで、キー名を一箇所にまとめて管理する
// 改修の時はここを変更すればいいだけになる
// このままコピーして別プロジェクトでの流用がしやすくなる
extension UserDefaults {
    // どこからでも唯一の文字列を返すコンピューティッドプロパティ
    private var qiitaAccessTokenKey: String { "qiitaAccessTokenKey" }
    // コンピューティッドプロパティとして宣言、get/setで動的に変更できるようにする
    var qiitaAccessToken: String {
        get {
            // qiitaAccessTokenKeyに対応するUserDefaultsに保存されている値を取得、なければ""を返す
            self.string(forKey: qiitaAccessTokenKey) ?? ""
        }
        set {
            // qiitaAccessTokenKeyに対応するUserDefaultsに新しい値を保存する
            self.setValue(newValue, forKey: qiitaAccessTokenKey)
        }
    }
}
// ストアドプロパティーは値を保持する
// コンピューテッドプロパティは値を保持せず算出する
