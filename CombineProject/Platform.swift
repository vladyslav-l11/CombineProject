//
//  Platform.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import UIKit

final class Platform: UseCaseProvider {
    
    // MARK: - UseCases
    var some: Any { "" }
    
    // MARK: - AppDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }
}
