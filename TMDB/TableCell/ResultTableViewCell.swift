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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureSearchResults(item: Result) {
        self.resultTitleLabel.text = item.nameTitle
        let urlStringBack = "https://image.tmdb.org/t/p/original\(item.backdropPath ?? "")"
        if item.backdropPath == nil {
            self.resultImageView.image = UIImage(named: "noimage")
        } else {
            self.resultImageView.sd_setImage(with: URL(string: urlStringBack), completed: nil)
        }
    }
    
}
