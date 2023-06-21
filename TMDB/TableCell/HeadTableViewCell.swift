//
//  HeadTableViewCell.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 14.06.2023.
//

import UIKit

class HeadTableViewCell: UITableViewCell {
    
    @IBOutlet var headImage: UIImageView!
    @IBOutlet var headTitle: UILabel!
    @IBOutlet var countriesLabel: UILabel!
    @IBOutlet var reliseLabel: UILabel!
    @IBOutlet var poularityLabel: UILabel!
    @IBOutlet var ganreLabel: UILabel!
    
    @IBOutlet var heartImageView: UIImageView!
    @IBOutlet var avaregeStack: UIStackView!
    @IBOutlet var star1AvarageLogo: UIImageView!
    @IBOutlet var star2AvarageLogo: UIImageView!
    @IBOutlet var star3AvarageLogo: UIImageView!

    let networkController = NetworkController()
    let coreDataController = CoreDataController.shared

    // MARK: - Load anower data from ID
    func loadDetailData(itemDetail: Result) {
        Task {
            do {
                let details = try await networkController.loadDetailsFromId(id: itemDetail.id)
                do {
                    self.countriesLabel.text = details?.productionCountries.first?.name ?? ""
                    let genres = details?.genres.map { $0.name }
                    self.ganreLabel.text = genres?.joined(separator: " | ")
                }
            } catch {
                print("Error load data from ID:\(itemDetail.id) - \(error)")
            }
        }
    }
    
    // MARK: - Configure
    func configure(item: Result) {

        loadDetailData(itemDetail: item)

        self.headTitle.text = item.nameTitle
        self.reliseLabel.text = String(item.airReleaseDate.prefix(4))
        
        RatingStars().ratingStars(for: item.voteAverage,
                                  self.star1AvarageLogo,
                                  self.star2AvarageLogo,
                                  self.star3AvarageLogo,
                                  label: self.poularityLabel)
        
        TryLoadImage().tryLoadImage(from: item.posterPath, to: self.headImage)
    }
    
}
