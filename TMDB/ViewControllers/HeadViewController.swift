//
//  FirstViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit
import SDWebImage

class HeadViewController: UIViewController {
    
    //    @IBOutlet var mainCollectionView: UICollectionView!
    @IBOutlet var segmentControll: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headImage: UIImageView!
    /// Search controller to help us with filtering items in the table view.
    private var resultsTableController: ResultsTableController!
    let netwotkController = NetworkController()

    
    var jsnData:[Result] = []
    var typeVideo: String = "movie"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControll.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        searchControllerSetup()
        
        load()
        
    }

// Load data from URL with network controller
    private func load() {
        Task.init {
            do {
                self.jsnData += try await netwotkController.loadNextPage()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.loadHeadImage()
                }
            } catch {
                print("Error load data\(error)")
            }
        }
    }
    
    
    private func loadSearchData() {
        Task.init {
            do {
                resultsTableController.searchData = try await netwotkController.searchPage()
                resultsTableController.tableViewSearchResult.reloadData()

            } catch {
                print("Error loading search data: \(error)")
            }
        }
    }
    
    
// Search controller setup
    func searchControllerSetup() {
        resultsTableController =
            self.storyboard?.instantiateViewController(withIdentifier: "ResultsTableController") as? ResultsTableController
        resultsTableController.tableView.delegate = resultsTableController
        resultsTableController.tableView.dataSource = resultsTableController
        let search = UISearchController(searchResultsController: resultsTableController)
        search.searchBar.delegate = self
        search.searchResultsUpdater = self
        search.searchBar.autocapitalizationType = .none
        self.navigationItem.searchController = search
        definesPresentationContext = true
        
    }
    
// Segmented controller action setup
    @objc func segmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: netwotkController.typeVideo = "movie"
        case 1: netwotkController.typeVideo = "tv"
        default: break
        }
        let headTitle =  sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "Movies"
        navigationItem.title = "Top \(headTitle)"
    }
    
    @IBAction func SegmentCntrAction(_ sender: Any) {
        UITableView.animate(
            withDuration: 0.25,
            animations: { self.tableView.alpha = 0},
            completion: {_ in
                self.jsnData.removeAll()
                self.netwotkController.pageLoaded = 1
                self.load()
            }
        )
        UITableView.animate(withDuration: 0.5) {
            self.tableView.alpha = 1
        }
    }
    
    //  Load image from first on TOP movie or tv
    func loadHeadImage() {
        guard let image = jsnData.first?.backdropPath,
              let imageUrl = URL(string: "https://image.tmdb.org/t/p/original\(image)") else {
            headImage.image = UIImage(named: "noimage")
            return
        }
        headImage.sd_setImage(with: imageUrl)
    }
    
    
}


// Search results
extension HeadViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        netwotkController.query = searchController.searchBar.text ?? ""
        self.loadSearchData()
        print(netwotkController.query)

    }

}

// TableView
extension HeadViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsnData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = jsnData[indexPath.row]
        cell.textLabel?.text = item.nameTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.overview = jsnData[indexPath.row].overview
        detailVC.favorTitle = jsnData[indexPath.row].nameTitle
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let lastIndexPath = indexPaths.last, lastIndexPath.row == jsnData.count - 1 {
            load()
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 1, y: 0.25)
        cell.transform = CGAffineTransform(translationX:
                                            cell.contentView.frame.width,
                                           y: cell.contentView.frame.height/1.5)
        cell.alpha = 0.25
        UIView.animate(withDuration: 0.25, delay: 0.005 * Double(indexPath.row)) {
            cell.alpha = 1
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            cell.transform = CGAffineTransform(translationX:
                                                cell.contentView.frame.width,
                                               y: cell.contentView.frame.height)
        }
    }
    
}

/*
 // CollectionView
 extension HeadViewController:
 UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 return jsnData.count
 }
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionCell", for: indexPath) as? MovieCollectionViewCell else { return UICollectionViewCell() }
 let item = jsnData[indexPath.item]
 cell.configure(item: item)
 return cell
 }
 
 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 guard let detailVC = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
 detailVC.overview = jsnData[indexPath.row].overview
 detailVC.favorTitle = jsnData[indexPath.row].nameTitle
 navigationController?.pushViewController(detailVC, animated: true)
 }
 
 func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
 let lastIndexPath = indexPaths.last
 let lastIndex = lastIndexPath?.item ?? 0
 let itemCount = collectionView.numberOfItems(inSection: 0)
 if lastIndex >= itemCount - 2 {
 load()
 }
 }
 }
 */
