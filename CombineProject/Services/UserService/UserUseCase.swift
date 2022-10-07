//
//  UserUseCase.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Foundation

protocol UserUseCase {
    func getUsers(params: [String: Any]) -> AsyncTask<[User]>
    func upload(params: [String: Any], progress: ((Double) -> Void)?) -> AsyncTask<Void>
}
