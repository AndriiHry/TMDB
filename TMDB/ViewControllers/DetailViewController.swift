//
//  DetailViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var detailImageView: UIImageView!
    @IBOutlet var detailTitleLabel: UILabel!
    @IBOutlet var ganreLabel: UILabel!
    @IBOutlet var poularityLabel: UILabel!
    @IBOutlet var avaregeStack: UIStackView!
    @IBOutlet var star1AvarageLogo: UIImageView!
    @IBOutlet var star2AvarageLogo: UIImageView!
    @IBOutlet var star3AvarageLogo: UIImageView!
    @IBOutlet var companyLabel: UILabel!
    @IBOutlet var reliseLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    
    @IBOutlet var youtubeView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    
    let networkController = NetworkController()
    var videoData: [VideData] = []
    var detailData: Result!
    
    var detailImage: String = ""
    var overview: String = ""
    var favorTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = detailData.nameTitle
        navigationController?.isNavigationBarHidden = false
        navigationItem.largeTitleDisplayMode = .never
        configureDetail(item: detailData)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
// MARK: - Configure
     func configureDetail(item: Result) {
         
         self.detailTitleLabel.text = item.origTitle
         self.overviewLabel.text = item.overview
         
         Task.init {
             do {
                 let details = try await networkController.loadDetailsFromId(id: item.id)
                 let company = details?.productionCompanies.map { $0.name }
                 self.companyLabel.text = company?.joined(separator: " | ")
                 let genres = details?.genres.map { $0.name }
                 self.ganreLabel.text = genres?.joined(separator: " | ")
             } catch {
                 print("Error load data from ID\(error)")
             }
             do {
                 self.videoData = try await networkController.loadVideoData(id: item.id)
                 self.collectionView.reloadData()
             }
             catch {
                 print("Error load video data from ID\(error)")
             }
         }

         self.reliseLabel.text = String(item.airReleaseDate.prefix(4))
         let voteAverage = round(item.voteAverage * 10) / 10
         self.poularityLabel.text = "\(voteAverage)"

         switch voteAverage {
         case 0...0.1:
             self.star1AvarageLogo.image = UIImage(systemName: "star")
             self.star2AvarageLogo.image = UIImage(systemName: "star")
             self.star3AvarageLogo.image = UIImage(systemName: "star")
         case 0.1...2:
             self.star1AvarageLogo.image = UIImage(systemName: "star.fill.left")
             self.star2AvarageLogo.image = UIImage(systemName: "star")
             self.star3AvarageLogo.image = UIImage(systemName: "star")
         case 2...4:
             self.star1AvarageLogo.image = UIImage(systemName: "star.fill")
             self.star2AvarageLogo.image = UIImage(systemName: "star")
             self.star3AvarageLogo.image = UIImage(systemName: "star")
         case 4...6:
             self.star1AvarageLogo.image = UIImage(systemName: "star.fill")
             self.star2AvarageLogo.image = UIImage(systemName: "star.fill.left")
             self.star3AvarageLogo.image = UIImage(systemName: "star")
         case 6...8:
             self.star1AvarageLogo.image = UIImage(systemName: "star.fill")
             self.star2AvarageLogo.image = UIImage(systemName: "star.fill")
             self.star3AvarageLogo.image = UIImage(systemName: "star")
         case 8...9:
             self.star1AvarageLogo.image = UIImage(systemName: "star.fill")
             self.star2AvarageLogo.image = UIImage(systemName: "star.fill")
             self.star3AvarageLogo.image = UIImage(systemName: "star.fill.left")
         case 9...10:
             self.star1AvarageLogo.image = UIImage(systemName: "star.fill")
             self.star2AvarageLogo.image = UIImage(systemName: "star.fill")
             self.star3AvarageLogo.image = UIImage(systemName: "star.fill")
         default: break
         }
         
         let urlStringBack = "https://image.tmdb.org/t/p/original\(item.backdropPath ?? "")"
         if item.backdropPath == nil {
             self.detailImageView.image = UIImage(named: "noimage")
         } else {
             self.detailImageView.sd_setImage(with: URL(string: urlStringBack), completed: nil)
         }
     }
}


// MARK: - Extension UICollectionViewDataSource, UICollectionViewDelegate
extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.videoLabel.text = videoData[indexPath.row].type
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let youtubeID = videoData[indexPath.row].key
        UIView.animate(withDuration: 0.75) {
            self.youtubeView.layer.opacity = 1
        }
       
    }
    
}
