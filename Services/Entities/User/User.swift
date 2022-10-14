//
//  User.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Foundation

public struct User {
    public let name: Name
    public let gender: String
    public let email: String
}

public extension User {
    struct Name: Decodable {
        public let title: String
        public let first: String
        public let last: String
    }
}
