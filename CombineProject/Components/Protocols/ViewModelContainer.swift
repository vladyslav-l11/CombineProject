//
//  ViewModelContainer.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 04.10.2022.
//

import Foundation

protocol ViewModelContainer: AnyObject {
    associatedtype ViewModel: BaseVM
    
    var viewModel: ViewModel? { get set }
    func bind()
}
