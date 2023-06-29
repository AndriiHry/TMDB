//
//  DetailViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit
import YouTubeiOSPlayerHelper

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
    @IBOutlet var buttonImage: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var youtubeView: YTPlayerView!
    @IBOutlet var collectionView: UICollectionView!
    
    let networkController = NetworkController()
    let coreDataController = CoreDataController.shared
    var videoData: [VideData] = []
    var detailData: Result!
    var isActive: Bool = false
    var selectedItems: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItemStyle()
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
    
    // MARK: - Load anower data from ID
    private func loadDetailData(itemDetail: Result) {
        Task.init {
            do {
                let details = try await
                networkController.loadDetailsWith(id: itemDetail.id, typeVideo: itemDetail.mediaType?.rawValue ?? "movie")
                self.videoData = try await
                networkController.loadVideoDataWith(id: itemDetail.id, typeVideo: itemDetail.mediaType?.rawValue ?? "movie")
                do {
                    let company = details?.productionCompanies.map { $0.name }
                    self.companyLabel.text = company?.joined(separator: " | ")
                    let genres = details?.genres.map { $0.name }
                    self.ganreLabel.text = genres?.joined(separator: " | ")
                    self.collectionView.reloadData()
                }
            } catch {
                print("Error load data from ID:\(itemDetail.id) - \(error)")
            }
        }
    }
    
    // MARK: - Configure
    func configureDetail(item: Result) {
        loadDetailData(itemDetail: item)
        
        self.detailTitleLabel.text = item.origTitle
        self.overviewLabel.text = item.overview
        self.reliseLabel.text = String(item.airReleaseDate.replacingOccurrences(of: "-", with: "."))
        RatingStars().ratingStars(for: item.voteAverage,
                                  self.star1AvarageLogo,
                                  self.star2AvarageLogo,
                                  self.star3AvarageLogo,
                                  label: self.poularityLabel)
        TryLoadImage().tryLoadImage(from: item.backdropPath, to: self.detailImageView)
        Task.init {
            let favoriteCollection = try await coreDataController.loadMoviesDB()
            if favoriteCollection.contains(where: { $0.id == Int64(item.id) }) {
                buttonImage.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                isActive = false
            } else {
                buttonImage.setImage(UIImage(systemName: "heart"), for: .normal)
                isActive = true
            }
        }
    }
    
    //MARK: - Navigation Controller Item setup
    private func navigationItemStyle() {
        self.title = detailData.nameTitle
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: - Save Button
    @IBAction func savePressedButton(_ sender: Any) {
        isActive.toggle()
        switch isActive {
        case true:
            buttonImage.setImage(UIImage(systemName: "heart"), for: .normal)
            Task.init {
                let favoriteCollection = try await coreDataController.loadMoviesDB()
                if let movieToDelete = favoriteCollection.first(where: { $0.id == Int64(detailData.id) }) {
                    coreDataController.deleteFromDB(movie: movieToDelete)
                }
            }
        case false:
            buttonImage.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            coreDataController.saveMoviesDB(movies: detailData)
        }
    }
    
}
// MARK: - End Class

// MARK: - Extension UICollectionViewDataSource, UICollectionViewDelegate
extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.identCollCell, for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.videoLabel.text = videoData[indexPath.row].type
        if selectedItems.contains(where: {$0 == videoData[indexPath.row].key}) {
            cell.circleView.backgroundColor = .red
        } else {
            cell.circleView.backgroundColor = .gray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let youtubeID = videoData[indexPath.row].key
        self.youtubeView.load(withVideoId: youtubeID)
        self.youtubeView.delegate = self
        selectedItems.append(youtubeID)
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            UIView.animate(withDuration: 0.5) {
                self.detailImageView.layer.opacity = 0.35
                self.activityIndicator.layer.opacity = 1
                cell.circleView.backgroundColor = .red
            }
        }
    }
    
}

// MARK: - YTPlayerViewDelegate
extension DetailViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.youtubeView.playVideo()
        UIView.animate(withDuration: 0.5, delay: 1) {
            self.youtubeView.layer.opacity = 1
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .ended {
                self.youtubeView.layer.opacity = 0
                self.activityIndicator.layer.opacity = 0
                self.detailImageView.layer.opacity = 1
        }
    }
}
