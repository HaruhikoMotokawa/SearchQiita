//
//  SceneDelegate.swift
//  SearchQiita
//
//  Created by 本川晴彦 on 2023/07/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let widowScene = (scene as? UIWindowScene) else { return }
        self.window = Router.shared.showRoot(windowScene: widowScene)
        QiitaAPI.shared.getItems(inputText: "Swift") { result in
            switch result {
                case .success(let ok):
                    ok.forEach { item in
                        print(item.user.id)
                        print(item.user.profileImageUrlStr)
                        print("_________________")
                    }
                    print("成功")
                case .failure(let error):
                    print(error)

            }
        }

    }

    // URLスキームでリダイレクトされてきた時に呼び出される
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // 受け取った最初のurlがないかチェック
        guard let url = URLContexts.first?.url else{
            return
        }
        // Routerに保持していた起動時のloginViewControllerのインスタンスを代入
        guard let vc = Router.shared.loginViewController else {
            fatalError()
        }
        vc.openURL(url)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

