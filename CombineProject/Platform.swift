//
//  Platform.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import UIKit
import NetworkLayer

final class Platform: UseCaseProvider {
    
    // MARK: - UseCases
    var user: UserUseCase
    
    // MARK: - Private properties
    private let network: Network
    private let environment: SwiftConfiguration
    private let authPlugin = AuthorizationPlugin()
    
    init() {
        environment = SwiftConfiguration.current
        network = Network(baseURL: URL(string: environment.baseUrl)!,
                          plugins: [APIErrorPlugin()])
        
        let context = ServiceContextProvider(network: network)
        user = UserService(context: context)
    }
    
    // MARK: - AppDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }
}
