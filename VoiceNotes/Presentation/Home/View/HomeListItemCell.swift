//
//  HomeListItemCell.swift
//  VoiceNotes
//
//  Created by nhatnt on 29/05/2022.
//

import Foundation

final class HomeListItemCell: UITableViewCell {
    static let reuseIdentifier = String(describing: HomeListItemCell.self)
    static let height = CGFloat(150)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    private var viewModel: HomeItemViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func fill(with viewModel: HomeItemViewModel) {
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
    }
}
