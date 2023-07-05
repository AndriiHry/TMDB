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
    
    func configure(for item: MovieCoreDB) {
        self.favoriteTitle.text = item.title
        TryLoad().picture(from: item.backdropPath, to: self.favoriteImage)
    }
    
}
