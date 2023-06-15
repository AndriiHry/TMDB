//
//  FirstViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit
import SDWebImage

class HeadViewController: UIViewController {
    
    @IBOutlet var segmentControll: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headImage: UIImageView!
    
    var resultsTableController: ResultsTableController!
    let netwotkController = NetworkController()
    
    var jsnData:[Result] = []
    var typeVideo: String = "movie"
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchControllerSetup()
        
        segmentControll.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        
        tableView.register(UINib(nibName: "HeadTableViewCell", bundle: nil), forCellReuseIdentifier: "HeadTableViewCell")
        
        
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
//                resultsTableController.searchData.removeAll()
                resultsTableController.searchData = try await self.netwotkController.searchPage()
                resultsTableController.tableViewSearchResult.reloadData()
            } catch {
                print("Error loading search data: \(error)")
            }
        }
    }
    
// Search controller setup
    func searchControllerSetup() {
        resultsTableController =
            self.storyboard?.instantiateViewController(withIdentifier: "ResultsTableController")as? ResultsTableController
        resultsTableController.tableView.delegate = resultsTableController
        resultsTableController.tableView.dataSource = resultsTableController
        resultsTableController.resultDidSelected = { [ weak self ] selectedResult in
            self?.showDetail(for: selectedResult)
        }
        resultsTableController.parentNavigationController = navigationController
        let search = UISearchController(searchResultsController: resultsTableController)
        search.searchBar.delegate = self
        search.searchResultsUpdater = self
        search.searchBar.autocapitalizationType = .none
        search.searchBar.tintColor = .white
        search.searchBar.searchTextField.textColor = .white
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
    
    // Setup Detail VC
    func showDetail(for data:Result) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.overview = data.overview
        detailVC.favorTitle = data.nameTitle
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// Search results
extension HeadViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText =
        searchController.searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        let searchItems = searchText.replacingOccurrences(of: " ", with: "%20")
        self.netwotkController.query = searchItems
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
            self.loadSearchData()
        })
    }
}

// TableView
extension HeadViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsnData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeadTableViewCell", for: indexPath) as? HeadTableViewCell else {return UITableViewCell()}
        let item = jsnData[indexPath.row]
        cell.configure(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetail(for: jsnData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let lastIndexPath = indexPaths.last, lastIndexPath.row == jsnData.count - 1 {
            load()
        }
    }

//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.transform = CGAffineTransform(scaleX: 1, y: 0.25)
//        cell.transform = CGAffineTransform(translationX:
//                                            cell.contentView.frame.width,
//                                           y: cell.contentView.frame.height/1.5)
//        cell.alpha = 0.25
//        UIView.animate(withDuration: 0.25, delay: 0.005 * Double(indexPath.row)) {
//            cell.alpha = 1
//            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
//            cell.transform = CGAffineTransform(translationX:
//                                                cell.contentView.frame.width,
//                                               y: cell.contentView.frame.height)
//        }
//    }
    
}
