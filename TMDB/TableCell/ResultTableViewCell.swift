//
//  ResultTableViewCell.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 15.06.2023.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    @IBOutlet var resultImageView: UIImageView!
    @IBOutlet var resultTitleLabel: UILabel!
    
    func configureSearchResults(item: Result) {
        self.resultTitleLabel.text = item.nameTitle
        TryLoad().picture(from: item.backdropPath, to: self.resultImageView)
    }
    
}
