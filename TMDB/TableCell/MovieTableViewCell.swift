//
//  MovieTableViewCell.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit
import SDWebImage

class MovieTableViewCell: UITableViewCell {
    @IBOutlet var favoriteImage: UIImageView!
    @IBOutlet var favoriteTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(item: Result) {
        self.favoriteTitle.text = item.nameTitle
        self.favoriteImage.sd_setImage(with: URL(string: "https://image.tmdb.org/t/p/original\(item.backdropPath)"), completed: nil)
    }
    
}
