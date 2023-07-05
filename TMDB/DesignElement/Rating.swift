//
//  RatingStars.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 20.06.2023.
//

import UIKit

class Rating {
    
    func stars(for vote: Double, _ starLeft: UIImageView, _ starCenter: UIImageView, _ starRight: UIImageView, label: UILabel) {
        let voteAverage = round(vote * 10) / 10
        label.text = "\(voteAverage)"
        switch vote {
        case 0...0.1:
            starLeft.image = UIImage(systemName: Constants.star)
            starCenter.image = UIImage(systemName: Constants.star)
            starRight.image = UIImage(systemName: Constants.star)
        case 0.1...2:
            starLeft.image = UIImage(systemName: Constants.starHalf)
            starCenter.image = UIImage(systemName: Constants.star)
            starRight.image = UIImage(systemName: Constants.star)
        case 2...4:
            starLeft.image = UIImage(systemName: Constants.starFill)
            starCenter.image = UIImage(systemName: Constants.star)
            starRight.image = UIImage(systemName: Constants.star)
        case 4...6:
            starLeft.image = UIImage(systemName: Constants.starFill)
            starCenter.image = UIImage(systemName: Constants.starHalf)
            starRight.image = UIImage(systemName: Constants.star)
        case 6...8:
            starLeft.image = UIImage(systemName: Constants.starFill)
            starCenter.image = UIImage(systemName: Constants.starFill)
            starRight.image = UIImage(systemName: Constants.star)
        case 8...9:
            starLeft.image = UIImage(systemName: Constants.starFill)
            starCenter.image = UIImage(systemName: Constants.starFill)
            starRight.image = UIImage(systemName: Constants.starHalf)
        case 9...10:
            starLeft.image = UIImage(systemName: Constants.starFill)
            starCenter.image = UIImage(systemName: Constants.starFill)
            starRight.image = UIImage(systemName: Constants.starFill)
        default: break
        }
    }
    
}
