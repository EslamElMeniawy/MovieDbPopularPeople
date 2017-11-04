//
//  ImagesTableViewCell.swift
//  MovieDbPopularPeople
//
//  Created by Eslam El-Meniawy on 11/4/17.
//  Copyright © 2017 Eslam El-Meniawy. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ImagesTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var profileImagesCollection: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
