//
//  HeadTableViewCell.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 14.06.2023.
//

import UIKit
import SDWebImage

class HeadTableViewCell: UITableViewCell {
    

    @IBOutlet var headImage: UIImageView!
    @IBOutlet var headTitle: UILabel!
    @IBOutlet var countriesLabel: UILabel!
    @IBOutlet var reliseLabel: UILabel!
    @IBOutlet var poularityLabel: UILabel!
    @IBOutlet var ganreLabel: UILabel!
    @IBOutlet var avaregeStack: UIStackView!

    
    
    let networkController = NetworkController()
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    

    func configure(item: Result) {
        Task.init {
            do {
                let details = try await networkController.loadDetailsFromId(id: item.id)
                DispatchQueue.main.async {
                    self.countriesLabel.text = details?.productionCountries.first?.name ?? ""
                    let genres = details?.genres.map { $0.name }
                    self.ganreLabel.text = genres?.joined(separator: " | ")
                }
            } catch {
                print("Error load data from ID\(error)")
            }
        }
        self.headTitle.text = item.nameTitle
        self.reliseLabel.text = String(item.airReleaseDate.prefix(4))
        let voteAverage = round(item.voteAverage * 10) / 10
        if voteAverage == 0 {
            self.avaregeStack.alpha = 0
        } else {
            self.poularityLabel.text = "\(voteAverage)"
            self.avaregeStack.alpha = 1
        }
        
        let urlStringBack = "https://image.tmdb.org/t/p/original\(item.posterPath ?? "")"
        if item.posterPath == nil {
            self.headImage.image = UIImage(named: "noimage")
        } else {
            self.headImage.sd_setImage(with: URL(string: urlStringBack), completed: nil)
        }
    }
    
}
