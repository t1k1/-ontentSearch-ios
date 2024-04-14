//
//  SceneDelegate.swift
//  СontentSearch-ios
//
//  Created by Aleksey Kolesnikov on 06.04.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let paramsViewController = ContentViewController()
        window.rootViewController = UINavigationController(rootViewController: paramsViewController)
        
        self.window = window
        window.makeKeyAndVisible()
    }
}

