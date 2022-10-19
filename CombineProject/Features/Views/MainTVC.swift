//
//  MainTVC.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 19.10.2022.
//

import UIKit

final class MainTVC: UITableViewCell {
    @IBOutlet private weak var label: UILabel!
    
    func setup(name: String) {
        label.text = name
    }
}
