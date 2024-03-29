//
//  TryLoadImage.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 20.06.2023.
//

import UIKit
import SDWebImage

class TryLoad {
    func picture(from url: String?, to image: UIImageView) {
        let urlString = "\(Constants.imageUrl)\(url ?? "")"
        if url == nil {
            image.image = UIImage(named: "noimage")
        } else {
            image.sd_setImage(with: URL(string: urlString), completed: nil)
        }
    }
}
