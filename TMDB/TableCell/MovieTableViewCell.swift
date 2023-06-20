//
//  MovieTableViewCell.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    @IBOutlet var favoriteImage: UIImageView!
    @IBOutlet var favoriteTitle: UILabel!
    
    func configure(item: MovieCoreDB) {
        self.favoriteTitle.text = item.title
        TryLoadImage().tryLoadImage(from: item.backdropPath, to: self.favoriteImage)
    }
    
}
