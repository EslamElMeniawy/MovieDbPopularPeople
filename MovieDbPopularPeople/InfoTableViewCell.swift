//
//  InfoTableViewCell.swift
//  MovieDbPopularPeople
//
//  Created by Eslam El-Meniawy on 11/4/17.
//  Copyright © 2017 Eslam El-Meniawy. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
