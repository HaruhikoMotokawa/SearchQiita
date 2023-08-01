
import UIKit
import Lottie

/// ログイン画面
final class LoginViewController: UIViewController {
    /// Lottieのアニメーション実行のフラグ
    private var isPlaying: Bool = false
    /// Lottieをインスタンス化
    private let animationView = LottieAnimationView()
    /// アニメーションを入れるコンテナビュー
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            guard let animation = LottieAnimation.named("login", subdirectory: nil) else {
                print("\(#line) file not found")
                return
            }
            animationView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(animationView)
            NSLayoutConstraint.activate([
                animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
                animationView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                animationView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
            // アニメーションの設定
            animationView.animation = animation
            // アニメーションをループ再生に設定
            animationView.loopMode = .loop
            // アニメーション実行を設定
            animationView.play()
        }
    }
    /// ログインしないで検索画面に移動するボタン
    @IBOutlet private weak var nonLoginButton: UIButton! {
        didSet {
            nonLoginButton.addTarget(self, action: #selector(nonLogin), for: .touchUpInside)
        }
    }
    /// ログインボタン、認証認可処理の開始
    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    /// リダイレクトされたら認可コードを受け取り、保存する
    ///  検索画面に遷移する
    internal func openURL(_ url: URL) {
        // 引数urlからクエリストリングに含まれるキーバリューペアの配列を取得
        guard let queryItems = URLComponents(string: url.absoluteString)?.queryItems,
              // "code"に該当するキーバリューペアを検索して取得 <- これが認可コード
              let code = queryItems.first(where: { $0.name == "code" })?.value,
              // "state"に該当するキーバリューペアを検索して取得
              let getState = queryItems.first(where: { $0.name == "state" })?.value,
              // getStateが指定したStateと同一かチェック
              getState == QiitaAPI.shared.qiitaState
        else {
            return
        }

        // 認可コードを受け取り、トークンを保存
        QiitaAPI.shared.postAccessToken(code: code) { result in
            switch result {
                case .success(let accessToken):
                    // アクセストークンを保存
                    // やっていることはUserDefaults.standard.set(_:forKey:)と同じ
                    UserDefaults.standard.qiitaAccessToken = accessToken.token
                    Router.shared.showSearch(from: self) // 画面遷移
                case .failure(let error):
                    print(error)
            }
        }
    }
    /// 認証画面へ遷移して認証処理の開始
    @objc private func login() {
        print("ログイン処理の開始")
        // Safariを開いてQiitaのOAuth認証画面にいく
        UIApplication.shared.open(QiitaAPI.shared.oAuthURL)
    }

    /// 認証処理をせずに検索画面に遷移
    @objc private func nonLogin() {
        print("ログイン処理の開始")
        Router.shared.showSearch(from: self)
    }
}
