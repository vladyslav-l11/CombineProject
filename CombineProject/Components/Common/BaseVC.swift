//
//  BaseVC.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 05.10.2022.
//

import UIKit
import Combine

class BaseVC: UIViewController {
    var subscriptions: Set<AnyCancellable> = []
}
