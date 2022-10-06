//
//  UseCaseProvider.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import Foundation

protocol HasUserUseCase {
    var user: UserUseCase { get set }
}

typealias UseCases = HasUserUseCase

protocol UseCaseProvider: UseCases {}
