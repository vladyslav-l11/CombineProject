//
//  UploadFileParams.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 06.10.2022.
//

import Foundation

struct UploadFileParams {
    enum CodingKeys: String, CodingKey {
        case data, name, mimeType, fileExtension
    }
    
    var data: Data
    var name: String
    var mimeType: String
    var fileExtension: String
    
    var parameters: [String: Any] {
        [
            CodingKeys.data.rawValue: data,
            CodingKeys.name.rawValue: name,
            CodingKeys.mimeType.rawValue: mimeType,
            CodingKeys.fileExtension.rawValue: fileExtension
        ]
    }
}
