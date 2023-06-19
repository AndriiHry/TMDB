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
    func configure(item: MovieCoreDB) {
        self.favoriteTitle.text = item.title
        
        let urlStringBack = "https://image.tmdb.org/t/p/original\(item.backdropPath ?? "")"
        if item.backdropPath == nil {
            self.favoriteImage.image = UIImage(named: "noimage")
        } else {
            self.favoriteImage.sd_setImage(with: URL(string: urlStringBack), completed: nil)
        }
    }
    
}
