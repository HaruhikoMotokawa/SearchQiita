
import Foundation
import Alamofire

enum APIError: Error {
    case postAccessToken
    case getItems
}

final class QiitaAPI {
    static let shared = QiitaAPI()
    private init() {}
    // 接続先の大元、親プログラム
    private let host = "https://qiita.com/api/v2"
    // 登録されたAPIクライアント（アプリの開発者）のIDで４０桁１６進数
    private let clientID = "e24cf0df2406166dcc9b7c96da2fc3ef579afc98"

    private let clientSecret = "7cf44190613bd5754508989a7945c4349eaf5423"
    let qiitaState = "bb17785d811bb1913ef54b0a7657de780defaa2d"

    // JSON形式のデータをSwiftに変換する（デコード）
    // 即時実行クロージャで定義、再利用できるようにする
    static let jsonDecoder: JSONDecoder = {
        // JSONDecoderのインスタンス化
        let decoder = JSONDecoder()
        // スネークケースからキャメルケースに変換する設定
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        // JSONの日付データISO 8601形式をSwiftのDateオブジェクトに変換
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    // パラメーター名をまとめているenum、ハードコーディングを避ける
    // enumのローバリューを用いている
    enum URLParameterName: String {
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case scope = "scope"
        case state = "state"
        case code  = "code"
    }

    // OAuthの認証画面を開くためのURL、コンピューテッドプロパティで定義でgetのみなので省略してる
    internal var oAuthURL: URL {
        // エンドポイントとは、Web APIで提供される機能やリソースを指定するためのURLの一部
        let endPoint = "/oauth/authorize"
        return URL(string: host + endPoint + "?" +
                   "\(URLParameterName.clientID.rawValue)=\(clientID)" + "&" +
                   "\(URLParameterName.scope.rawValue)=read_qiita" + "&" +
                   "\(URLParameterName.state.rawValue)=\(qiitaState)")!
    }

    // アクセストークンを取得するメソッド
    // 引数に認可コード
    // 完了時にコールバック関数が呼ばれ、アクセストークンオブジェクトまたはエラーオブジェクトを引数にとる
    // = nilはデフォルト値でこのコールバック関数がオプションであることを明示してる
    internal func postAccessToken(code: String, completion: ((Result<QiitaAccessTokenModel, Error>) -> Void)? = nil) {
        // エンドポイントをアクセストークンに指定
        let endPoint = "/access_tokens"
        // アクセストークン取得の問い合わせ先URLを作成
        guard let url = URL(string: host + endPoint + "?" +
                            "\(URLParameterName.clientID.rawValue)=\(clientID)" + "&" +
                            "\(URLParameterName.clientSecret.rawValue)=\(clientSecret)" + "&" +
                            "\(URLParameterName.code)=\(code)") else {
            completion?(.failure(APIError.postAccessToken))
            return
        }
        // Alamofireを使用してアクセストークンを取得する
        // 作成したurlに問い合わせ、HTTPSメソッドであるポストを指定、responseJSONメソッドでJSONE形式で取得を指定
        AF.request(url, method: .post).responseJSON { (response) in
            do {
                guard
                    // 返ってきたデータを_data定数に取得、_dataとしているのはData型とは異なるローカル定数であることを示す
                    let _data = response.data else {
                    // エラーを返して終了する
                    completion?(.failure(APIError.postAccessToken))
                    return
                }
                // アクセストークンを取得する、jsonDecoderのdecodeを使って_dataを元にQiitaAccessTokenModelに変換する
                let accessToken = try QiitaAPI.jsonDecoder.decode(QiitaAccessTokenModel.self, from: _data)
                // 成功したらaccessTokenを返す
                completion?(.success(accessToken))
            } catch let error {
                // 失敗したらエラーを返す
                completion?(.failure(error))
            }
        }
    }

    // QiitaAPIから必要なデータを取得する
    // 引数はコールバック関数でデフォルトnil
    internal func getItems(inputText: String, completion: ((Result<[QiitaItemModel], Error>) -> Void)? = nil) {
        // エンドポイントを「記事の一覧を作成日時の降順で返します。」に指定
        let endPoint = "/items"

        // アクセスするurlを作成
        guard let url = URL(string: host + endPoint),
              // アクセストークンが空だったら抜ける
              !UserDefaults.standard.qiitaAccessToken.isEmpty else {
            completion?(.failure(APIError.getItems))
            return
        }

        // 入力した文字を日本語で認識できるように変換
        let encodeString = inputText.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!

        // 検索ワードとして設定、記事のタイトルに該当する文字列で検索
        let searchWord = "title" + ":" + encodeString

        // 表示する数をparametersに定義
        let parameters = [
            "page": "1", // 最初のページ (初期値は１)
            "per_page": "20", // １ページあたりの要素数（初期値は２０）
            "query": searchWord
        ]

        // Alamofireを使用してデータを取得
        // 作成したurlに問い合わせ、HTTPSメソッドであるゲットを指定、取得パラメータと含めるヘッダーを指定、responseJSONメソッドでJSONE形式で取得を指定
        AF.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            do {
                guard
                    // 返ってきたデータを_data定数に取得、_dataとしているのはData型とは異なるローカル定数であることを示す
                    let _data = response.data else {
                    // エラーを返して終了する
                    completion?(.failure(APIError.getItems))
                    return
                }
                // 返ってきたレスポンスをswiftのQiitaItemModelにデコードする
                let items = try QiitaAPI.jsonDecoder.decode([QiitaItemModel].self, from: _data)
                completion?(.success(items))
            } catch let error {
                completion?(.failure(error))
            }
        }
    }

    // QiitaAPIから必要なデータを取得する
    // 引数はコールバック関数でデフォルトnil
    internal func getMyArticle(completion: ((Result<[QiitaItemModel], Error>) -> Void)? = nil) {
        // エンドポイントを「記事の一覧を作成日時の降順で返します。」に指定
        let endPoint = "/authenticated_user/items"

        // アクセスするurlを作成
        guard let url = URL(string: host + endPoint),
              // アクセストークンが空だったら抜ける
              !UserDefaults.standard.qiitaAccessToken.isEmpty else {
            completion?(.failure(APIError.getItems))
            return
        }

        // qiitaAccessTokenを使ってAuthorizationフィールドをヘッダーに追加
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer \(UserDefaults.standard.qiitaAccessToken)"
                ]
        // 表示する数をparametersに定義
        let parameters = [
            "page": "1", // 最初のページ (初期値は１)
            "per_page": "20", // １ページあたりの要素数（初期値は２０）
        ]

        // Alamofireを使用してデータを取得
        // 作成したurlに問い合わせ、HTTPSメソッドであるゲットを指定、取得パラメータと含めるヘッダーを指定、responseJSONメソッドでJSONE形式で取得を指定
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            do {
                guard
                    // 返ってきたデータを_data定数に取得、_dataとしているのはData型とは異なるローカル定数であることを示す
                    let _data = response.data else {
                    // エラーを返して終了する
                    completion?(.failure(APIError.getItems))
                    return
                }
                // 返ってきたレスポンスをswiftのQiitaItemModelにデコードする
                let items = try QiitaAPI.jsonDecoder.decode([QiitaItemModel].self, from: _data)
                completion?(.success(items))
            } catch let error {
                completion?(.failure(error))
            }
        }
    }
}
