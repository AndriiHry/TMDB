//
//  FirstViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit
import Lottie

class HeadViewController: UIViewController {
    
    @IBOutlet var launchView: UIView!
    @IBOutlet var animationView: LottieAnimationView!
    @IBOutlet var segmentControll: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headImage: UIImageView!
    
    var resultsTableController: ResultsTableController!
    let netwotkController = NetworkController()
    let coreDataController = CoreDataController.shared
    
    var jsnData: [Result] = []
    var favoriteData: [MovieCoreDB] = []
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        navigationController?.tabBarController?.tabBar.isHidden = true
        self.tableView.register(UINib(nibName: Constants.identHeadCell, bundle: nil),
                                forCellReuseIdentifier: Constants.identHeadCell)
        self.load()
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.0
        animationView.play()
        UIView.animate(withDuration: 0.5, delay: 3.5) {
            self.launchView.alpha = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.navigationItemStyle()
            self.searchControllerSetup()
            self.segmentControll.addTarget(self, action: #selector(self.segmentAction), for: .valueChanged)
        }
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
                TryLoad().picture(from: self.jsnData.first?.backdropPath, to: self.headImage)
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
    
    //MARK: - Load CoreData
    private func loadFavoriteCollection() {
        Task.init {
            do {
                favoriteData = try await self.coreDataController.loadMoviesDB()
            } catch {
                print("Error loading Favorite data: \(error)")
            }
        }
    }
    
    //MARK: - Navigation Controller Item setup
    private func navigationItemStyle() {
        self.navigationController?.tabBarController?.tabBar.isHidden = false
        self.overrideUserInterfaceStyle = .light
        self.navigationController?.navigationBar.tintColor = .lightGray
        self.tabBarController?.overrideUserInterfaceStyle = .light
        self.tabBarController?.tabBar.tintColor = UIColor(named: "title")
    }
        
    //MARK: - Search controller setup
    func searchControllerSetup() {
        resultsTableController =
        self.storyboard?.instantiateViewController(withIdentifier: Constants.identResultsVC) as? ResultsTableController
        resultsTableController.tableView.delegate = resultsTableController
        resultsTableController.tableView.dataSource = resultsTableController
        resultsTableController.resultDidSelected = { [weak self] itemResult in
            var updateResult = itemResult
            updateResult.mediaType = .init(rawValue: self?.netwotkController.typeVideo ?? Constants.movie)
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
        case 0: netwotkController.typeVideo = Constants.movie
        case 1: netwotkController.typeVideo = Constants.tv
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
                UITableView.animate(withDuration: 0.25) {
                    self.tableView.alpha = 1
                }
            }
        )
    }
    
    //MARK: - Setup Detail VC
    func showDetail(for data: Result) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: Constants.identDetailVC)
                as? DetailViewController else { return }
        detailVC.detailData = data
        navigationController?.pushViewController(detailVC, animated: true)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identHeadCell, for: indexPath)
                as? HeadTableViewCell else {return UITableViewCell()}
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
