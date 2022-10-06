//
//  UserService.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import NetworkLayer

final class UserService {
    private let context: ServiceContext
    
    init(context: ServiceContext) {
        self.context = context
    }
}

extension UserService: UserUseCase {
    func getUsers(params: [String: Any]) -> AsyncTask<[User]> {
        context.network
            .request(API.Users.getUsers(params: params))
            .decode(APIResponse<[User.Response]>.self)
            .mapToAppError()
            .map { $0.results.map(User.init) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func upload(params: [String: Any]) -> AsyncTask<Void> {
        context.network
            .request(API.Users.uplaod(params: params))
            .mapToAppError()
            .mapToVoid()
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
