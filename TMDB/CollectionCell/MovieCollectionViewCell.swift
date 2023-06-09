//
//  MovieCollectionViewCell.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 07.06.2023.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var mainTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

     func configure(item: Result) {
         self.mainTitle.text = item.nameTitle
         self.mainImage.sd_setImage(with: URL(string: "https://image.tmdb.org/t/p/original\(item.posterPath)"), completed: nil)
     }
    
    
}
