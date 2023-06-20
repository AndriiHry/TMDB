//
//  RatingStars.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 20.06.2023.
//

import UIKit

class RatingStars {
    
    func ratingStars(for vote: Double, _ starLeft: UIImageView, _ starCenter: UIImageView, _ starRight: UIImageView, label: UILabel) {
        let voteAverage = round(vote * 10) / 10
        label.text = "\(voteAverage)"
        switch vote {
        case 0...0.1:
            starLeft.image = UIImage(systemName: "star")
            starCenter.image = UIImage(systemName: "star")
            starRight.image = UIImage(systemName: "star")
        case 0.1...2:
            starLeft.image = UIImage(systemName: "star.fill.left")
            starCenter.image = UIImage(systemName: "star")
            starRight.image = UIImage(systemName: "star")
        case 2...4:
            starLeft.image = UIImage(systemName: "star.fill")
            starCenter.image = UIImage(systemName: "star")
            starRight.image = UIImage(systemName: "star")
        case 4...6:
            starLeft.image = UIImage(systemName: "star.fill")
            starCenter.image = UIImage(systemName: "star.fill.left")
            starRight.image = UIImage(systemName: "star")
        case 6...8:
            starLeft.image = UIImage(systemName: "star.fill")
            starCenter.image = UIImage(systemName: "star.fill")
            starRight.image = UIImage(systemName: "star")
        case 8...9:
            starLeft.image = UIImage(systemName: "star.fill")
            starCenter.image = UIImage(systemName: "star.fill")
            starRight.image = UIImage(systemName: "star.fill.left")
        case 9...10:
            starLeft.image = UIImage(systemName: "star.fill")
            starCenter.image = UIImage(systemName: "star.fill")
            starRight.image = UIImage(systemName: "star.fill")
        default: break
        }
    }
    
}
