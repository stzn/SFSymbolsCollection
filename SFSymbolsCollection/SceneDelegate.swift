//
//  SceneDelegate.swift
//  SFSymbolsCollection
//
//  Created by Shinzan Takata on 2020/03/13.
//  Copyright © 2020 shiz. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let tab = UITabBarController()

            let store = InMemoryFavoriteSymbolStore()
//            let categoriesViewController = UINavigationController(
//                rootViewController: NestedCategoriesViewController(frame: window.bounds, store: store))
            // Change if want grid style layout
            let categoriesViewController = UINavigationController(
                rootViewController: CategoriesViewController(frame: window.bounds, store: store))
            categoriesViewController.tabBarItem = UITabBarItem(title: "old API", image: nil, tag: 0)

            let categoriesNewAPIViewController = UINavigationController(
            rootViewController: CategoriesNewAPIViewController(frame: window.bounds, store: store))
            categoriesNewAPIViewController.tabBarItem = UITabBarItem(title: "new API", image: nil, tag: 1)

            let categoriesView = UINavigationController(rootViewController:
                UIHostingController(rootView: CategoriesView(store: store)))
            categoriesView.tabBarItem = UITabBarItem(title: "SwiftUI", image: nil, tag: 2)

            tab.viewControllers = [categoriesViewController, categoriesNewAPIViewController, categoriesView]
            window.rootViewController = tab
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

