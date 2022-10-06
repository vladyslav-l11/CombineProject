//
//  ServiceContextProvider.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import NetworkLayer

final class ServiceContextProvider: ServiceContext {
    
    // MARK: - Properties
    let network: Network
    
    // MARK: - Lifecycle
    init(network: Network) {
        self.network = network
    }
}
