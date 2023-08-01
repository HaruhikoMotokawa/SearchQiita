
import UIKit
import Lottie

final class LoginViewController: UIViewController {

    private var isPlaying: Bool = false
    // Lottieをインスタンス化
    private let animationView = LottieAnimationView()
    // アニメーションを入れるコンテナビュー
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
            animationView.animation = animation
            animationView.loopMode = .loop
            animationView.play()
        }
    }


    @IBOutlet private weak var nonLoginButton: UIButton! {
        didSet {
            nonLoginButton.addTarget(self, action: #selector(nonLogin), for: .touchUpInside)
        }
    }


    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

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
    @objc private func login() {
        print("ログイン処理の開始")
        // Safariを開いてQiitaのOAuth認証画面にいく
        UIApplication.shared.open(QiitaAPI.shared.oAuthURL)
    }

    @objc private func nonLogin() {
        print("ログイン処理の開始")
        Router.shared.showSearch(from: self)
    }
}
