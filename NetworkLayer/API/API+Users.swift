//
//  API+Certificates.swift
//  NetworkLayer
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Foundation

extension API {
    public enum Users: RequestConvertible {
        case getUsers(params: [String: Any])
        case uplaod(params: [String: Any])
        
        public var path: String {
            switch self {
            case .getUsers, .uplaod:
                return "api/"
            }
        }
        
        public var method: HTTPMethod {
            switch self {
            case .getUsers:
                return .get
            case .uplaod:
                return .post
            }
        }
        
        public var task: Network.Task {
            switch self {
            case .getUsers(let params):
                return .requestCompositeParameters(bodyParameters: [:],
                                                   bodyEncoding: .url(.default),
                                                   urlParameters: params)
            case .uplaod(let params):
                return .uploadMultipart {
                    guard let data = params["data"] as? Data,
                          let name = params["name"] as? String,
                          let mimeType = params["mimeType"] as? String,
                          let fileExtension = params["fileExtension"] as? String else {
                              return
                          }
                    $0.append(data,
                              withName: "file",
                              fileName: "\(name).\(fileExtension)",
                              mimeType: mimeType)
                }
            }
        }
    }
}
