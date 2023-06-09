//
//  FirstViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit

class HeadViewController: UIViewController {
    
    //    @IBOutlet var mainCollectionView: UICollectionView!
    @IBOutlet var segmentControll: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    
    let netwotkController = NetworkController()
    
    var jsnData:[Result] = []    
    var typeVideo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //      CollectionView
        //        mainCollectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MainCollectionCell")
        //        setupCollectionViewLayout()
        //      Search bar isHiden
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        self.navigationItem.searchController = search
        //      SegmentedController
        segmentControll.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        
        load()
        
    }
    
    private func load() {
           Task.init {
               do {
                   self.jsnData += try await netwotkController.loadNextPage()
                   self.tableView.reloadData()
               } catch {
                   print("Error load data\(error)")
               }
           }
       }
    
    @objc func segmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: typeVideo = "movie"
        case 1: typeVideo = "tv"
        default: break
        }
        let headTitle =  sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "Movies"
        navigationItem.title = "Top \(headTitle)"
    }
    
    @IBAction func SegmentCntrAction(_ sender: Any) {
        UITableView.animate(
            withDuration: 0.25,
            animations: { self.tableView.alpha = 0},
            completion: {_ in self.jsnData.removeAll()}
        )
        defer {
            UITableView.animate(withDuration: 0.5) {
                self.tableView.alpha = 1
            }
        }
        Task.init {
            do {
                self.jsnData = try await netwotkController.loadData(page: 1, trend: typeVideo)
                self.tableView.reloadData()
            } catch {
                print("Error load data\(error)")
            }
        }
    }
    
    
    
    
    /*
     private func setupCollectionViewLayout() {
     let layout = UICollectionViewFlowLayout()
     layout.scrollDirection = .horizontal
     layout.itemSize = CGSize(
     width: UIScreen.main.bounds.width - 10,
     height: UIScreen.main.bounds.height)
     layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
     layout.minimumLineSpacing = 10
     mainCollectionView.collectionViewLayout = layout
     }
     */
}


// Search results
extension HeadViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text ?? "")
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
