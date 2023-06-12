//
//  MovieCollectionViewCell.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 07.06.2023.
//

import UIKit
import SDWebImage

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var mainTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func configure(item: Result) {
        self.mainTitle.text = item.nameTitle
        guard let image = item.backdropPath,
              let imageUrl = URL(string: "https://image.tmdb.org/t/p/original\(image)") else {
            self.mainImage.image = UIImage(named: "noimage")
            return
        }
        self.mainImage.sd_setImage(with: imageUrl, completed: nil)
    }
    
}
