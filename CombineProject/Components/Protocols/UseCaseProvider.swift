//
//  UseCaseProvider.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import Foundation

internal protocol HasSomeUsecase {
    var some: Any { get }
}

typealias UseCases = HasSomeUsecase

protocol UseCaseProvider: UseCases {}
