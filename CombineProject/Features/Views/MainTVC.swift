//
//  MainTVC.swift
//  CombineProject
//
//  Created by Vladyslav Lysenko on 19.10.2022.
//

import UIKit
import Services

protocol MainTVCDelegate: AnyObject {
    func didTapRemove(_ cell: MainTVC, with user: User)
}

final class MainTVC: UITableViewCell {
    @IBOutlet private weak var label: UILabel!
    
    private weak var delegate: MainTVCDelegate?
    private var user: User?
    
    func setup(user: User, delegate: MainTVCDelegate) {
        label.text = "\(user.name.first) \(user.name.last)"
        self.user = user
        self.delegate = delegate
        
        let contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        addInteraction(contextMenuInteraction)
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension MainTVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let remove = UIAction(title: "Remove",
                                  image: UIImage(systemName: "trash"),
                                  attributes: .destructive) { [weak self] _ in
                guard let self = self, let user = self.user else { return }
                self.delegate?.didTapRemove(self, with: user)
            }
            return UIMenu(title: "User Menu", children: [remove])
        }
    }
}
