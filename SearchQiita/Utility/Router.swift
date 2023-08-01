

import UIKit
// 画面遷移を担うクラスでシングルトン
final class Router {
    // static let shared = Router()を丁寧に書くとこうなる
    static let shared: Router = .init()
    private init() {}

    // インスタンスを保持するためのプロパティ
    internal var loginViewController: LoginViewController?

    // 起動経路
    internal func showRoot(windowScene: UIWindowScene) -> UIWindow?{
        let window = UIWindow(windowScene: windowScene)
        guard let vc = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as? LoginViewController else {
            return nil
        }
        self.loginViewController = vc
        let nav = UINavigationController(rootViewController: vc)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        return window
    }

    internal func showSearch(from: UIViewController) {
        guard let toVC = UIStoryboard(name: "Search", bundle: nil).instantiateInitialViewController() else { return }
        show(from: from, to: toVC)
    }

    internal func showWeb(from: UIViewController, qiitaItemModel: QiitaItemModel) {
        guard let toVC = UIStoryboard(name: "Web", bundle: nil).instantiateInitialViewController() as? WebViewController else { return }
        toVC.configure(qiitaItemModel: qiitaItemModel)
        show(from: from, to: toVC)
    }
}

private extension Router {
    // 基本の画面遷移メソッド、アニメーションはデフォルト引数でtrue
    func show(from: UIViewController, to: UIViewController, animated: Bool = true) {
        //　移動元がnavigationControllerだったら
        if let nav = from.navigationController {
            // プッシュ遷移
            nav.pushViewController(to, animated: animated)
        } else { // 違うのなら
            // モーダル遷移
            from.present(to, animated: animated)
        }
    }
}
