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
    
    var jsnData: [Result] = []
    var favoriteData: [MovieCoreDB] = []
    var timer: Timer?
    let headIdentify: String = "HeadTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchControllerSetup()
        segmentControll.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        tableView.register(UINib(nibName: headIdentify, bundle: nil), forCellReuseIdentifier: headIdentify)
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
                resultsTableController.searchData = try await self.netwotkController.searchPage()
                resultsTableController.tableViewSearchResult.reloadData()
            } catch {
                print("Error loading search data: \(error)")
            }
        }
    }
    
    //MARK: - Search controller setup
    func searchControllerSetup() {
        resultsTableController =
        self.storyboard?.instantiateViewController(withIdentifier: "ResultsTableController")as? ResultsTableController
        resultsTableController.tableView.delegate = resultsTableController
        resultsTableController.tableView.dataSource = resultsTableController
        resultsTableController.resultDidSelected = { [weak self] selectedResult in
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
        UITableView.animate(withDuration: 0.75) {
            self.tableView.alpha = 1
        }
    }
    
    //MARK: - Setup Detail VC
    func showDetail(for data: Result) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.detailData = data
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    //MARK: - Load CoreData
    func loadFavoriteCollection(){
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: headIdentify, for: indexPath) as? HeadTableViewCell else {return UITableViewCell()}
        let item = jsnData[indexPath.row]
        if favoriteData.contains(where: { $0.id == Int64(item.id) }) {
            cell.heartImageView.layer.opacity = 1
        } else {
            cell.heartImageView.layer.opacity = 0
        }
        cell.configure(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetail(for: jsnData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let move = UIContextualAction(style: .normal, title: "Add to ♡") { [weak self] (action, view, completionHandler) in
            self?.coreDataController.saveMoviesDB(movies: self!.jsnData[indexPath.row])
            completionHandler(true)
        }
        move.backgroundColor = UIColor(named: "BG")
        return UISwipeActionsConfiguration(actions: [move])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete ♡") { [weak self ] (action, view, completionHandler) in
//            self?.coreDataController.deleteFromDB(movie: <#T##MovieCoreDB#>)
            completionHandler(true)
        }
//        delete.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if let lastIndexPath = indexPaths.last, lastIndexPath.row == jsnData.count - 1 {
            load()
        }
    }
    
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        AnimationTableView().cell(cell, forRowAt: indexPath)
    //    }
    
}
