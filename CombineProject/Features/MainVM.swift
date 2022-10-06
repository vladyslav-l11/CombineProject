//
//  MainVM.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Combine

final class MainVM: BaseVM, UseCasesConsumer {
    typealias UseCases = HasUserUseCase
    
    @Published private(set) var users: [User]?
    
    init(useCases: UseCases) {
        super.init()
        self.useCases = useCases
    }
    
    func getUsers(params: UserParams) {
        useCases.user
            .getUsers(params: params.parameters)
            .attach(value: \.users, error: \.error, on: self)
            .store(in: &subscriptions)
    }
}
