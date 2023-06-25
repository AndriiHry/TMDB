//
//  FirstViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit

class HeadViewController: UIViewController {
    
    @IBOutlet var segmentControll: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headImage: UIImageView!
    
    var resultsTableController: ResultsTableController!
    let netwotkController = NetworkController()
    let coreDataController = CoreDataController.shared
    
    let identHeadCell: String = "HeadTableViewCell"
    let identResultsVC: String = "ResultsTableController"
    let identDetailVC: String = "DetailViewController"
    
    var jsnData: [Result] = []
    var favoriteData: [MovieCoreDB] = []
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        navigationController?.navigationBar.tintColor = .lightGray
        tabBarController?.overrideUserInterfaceStyle = .light
        tabBarController?.tabBar.tintColor = UIColor(named: "title")
        searchControllerSetup()
        segmentControll.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        tableView.register(UINib(nibName: identHeadCell, bundle: nil), forCellReuseIdentifier: identHeadCell)
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        coreDataController.delegate = self
        self.tableView.reloadData()
    }

    //MARK: - Load data from URL with network controller
    private func load() {
        self.loadFavoriteCollection()
        Task.init {
            do {
                self.jsnData += try await netwotkController.loadNextPage()
                TryLoadImage().tryLoadImage(from: self.jsnData.first?.backdropPath, to: self.headImage)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error load data\(error)")
            }
        }
    }
    
    private func loadSearchData() {
        Task.init {
            do {
                resultsTableController.searchData = try await
                self.netwotkController.searchPageFor(typeVideo: netwotkController.typeVideo)
                resultsTableController.tableViewSearchResult.reloadData()
            } catch {
                print("Error loading search data: \(error)")
            }
        }
    }
    
    //MARK: - Search controller setup
    func searchControllerSetup() {
        resultsTableController =
        self.storyboard?.instantiateViewController(withIdentifier: identResultsVC) as? ResultsTableController
        resultsTableController.tableView.delegate = resultsTableController
        resultsTableController.tableView.dataSource = resultsTableController
        resultsTableController.resultDidSelected = { [weak self] itemResult in
            var updateResult = itemResult
            updateResult.mediaType = .init(rawValue: self?.netwotkController.typeVideo ?? "movie")
            self?.showDetail(for: updateResult)
        }
        resultsTableController.parentNavigationController = navigationController
        let search = UISearchController(searchResultsController: resultsTableController)
        search.searchBar.delegate = self
        search.searchResultsUpdater = self
        search.searchBar.tintColor = .lightGray
        search.searchBar.searchTextField.textColor = .white
        search.searchBar.barStyle = .black
        self.navigationItem.searchController = search
        definesPresentationContext = true
    }
    
    //MARK: - Segmented controller action setup
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
        UITableView.animate(withDuration: 0.75, delay: 0.01) {
            self.tableView.alpha = 1
        }
    }
    
    //MARK: - Setup Detail VC
    func showDetail(for data: Result) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: identDetailVC) as? DetailViewController else { return }
        detailVC.detailData = data
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    //MARK: - Load CoreData
    func loadFavoriteCollection() {
        Task.init {
            do {
                favoriteData = try await self.coreDataController.loadMoviesDB()
            } catch {
                print("Error loading Favorite data: \(error)")
            }
        }
    }
    
}
// MARK: - End Class

// MARK: - CoreDataController Delegate
extension HeadViewController: CoreDataControllerDelegate {
    func favoriteMoviesUpdated() {
        load()
    }
}


//MARK: - Search results
extension HeadViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText =
        searchController.searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        let searchItems = searchText.replacingOccurrences(of: " ", with: "%20")
        self.netwotkController.query = searchItems
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] (_) in
            self?.loadSearchData()
        })
    }
}

//MARK: -  HeadViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching
extension HeadViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsnData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identHeadCell, for: indexPath) as? HeadTableViewCell else {return UITableViewCell()}
        let item = jsnData[indexPath.row]
        cell.configure(for: item, and: favoriteData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetail(for: jsnData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let move = UIContextualAction(style: .normal, title: "Add to ♡") { [weak self](action, view, completionHandler) in
            self?.coreDataController.saveMoviesDB(movies: self!.jsnData[indexPath.row])
            completionHandler(true)
        }
        move.backgroundColor = UIColor(named: "BG")
        return UISwipeActionsConfiguration(actions: [move])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete ♡") { [weak self](action, view, completionHandler) in
            if let movie = self?.favoriteData.first(where: { $0.id == Int64(self!.jsnData[indexPath.row].id) }){
                self?.coreDataController.deleteFromDB(movie: movie)
            }
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let lastIndexPath = indexPaths.last, lastIndexPath.row == jsnData.count - 1 {
            load()
        }
    }
    
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
                AnimationTableView().cell(cell, forRowAt: indexPath)
        }
    
}
