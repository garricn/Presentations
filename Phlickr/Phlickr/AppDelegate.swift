//
//  AppDelegate.swift
//  Phlickr
//
//  Created by Garric Nahapetian on 10/20/16.
//  Copyright © 2016 Garric Nahapetian. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let frame = UIScreen.mainScreen().bounds
        window = UIWindow(frame: frame)
        window?.rootViewController = UINavigationController(rootViewController: resolvedVC())
        window?.makeKeyAndVisible()
        return true
    }
}

func resolvedVC() -> UIViewController {
    return ViewController(
        viewModel: ViewModel(
            fetcher: Fetcher()
        )
    )
}
