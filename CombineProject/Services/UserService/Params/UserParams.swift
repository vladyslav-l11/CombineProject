//
//  UserParams.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 06.10.2022.
//

import Foundation

struct UserParams {
    enum CodingKeys: String, CodingKey {
        case results
    }
    
    let results: Int
    
    var parameters: [String: Any] {
        [CodingKeys.results.rawValue: results]
    }
}
