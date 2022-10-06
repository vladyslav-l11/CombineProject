//
//  User.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Foundation

struct User {
    let name: Name
    let gender: String
    let email: String
}

extension User {
    struct Name: Decodable {
        let title: String
        let first: String
        let last: String
    }
}
