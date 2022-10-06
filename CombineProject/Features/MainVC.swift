//
//  ViewController.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 29.08.2022.
//

import UIKit

extension MainVC: Makeable {
    static func make() -> MainVC {
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainVC") { coder in
            MainVC(coder: coder)
        }
    }
}

final class MainVC: BaseVC, ViewModelContainer {
    var viewModel: MainVM?
    
    init?(viewModel: MainVM, coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        //getUsers(params: UserParams(results: 10))
    }
    
    func bind() {
        viewModel?.$users
            .compactMap { $0 }
            .sink {
                $0.forEach { user in
                    print("\(user.name.first) \(user.name.last)")
                }
            }
            .store(in: &subscriptions)
        
        viewModel?.$error
            .compactMap { $0 }
            .sink {
                print($0.localizedDescription)
            }
            .store(in: &subscriptions)
    }
    
    func getUsers(params: UserParams) {
        viewModel?.getUsers(params: params)
    }
}

