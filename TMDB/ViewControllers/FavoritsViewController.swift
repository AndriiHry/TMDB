//
//  SecondViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit

class FavoritsViewController: UIViewController {

    @IBOutlet var favoriteTableView: UITableView!
    
    var myData:[MovieCoreDB] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        favoriteTableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoritesTableCell")
        
        tabBarController?.delegate = self
        loadData()
    }

    //MARK: -  Load from Core DB
    private func loadData() {
        Task.init {
            do {
                self.myData = try await CoreDataController.shared.loadMoviesDB()
                self.favoriteTableView.reloadData()
            } catch {
                print("Error load data from Core DB \(error)")
            }
        }
    }
    
    // MARK: - Setup Detail VC
    func showDetail(for data: MovieCoreDB) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        let dataModify: Result = {
            Result(adult: false,
                   backdropPath: data.backdropPath,
                   id: Int(data.id),
                   title: data.title,
                   originalLanguage: "",
                   originalTitle: data.originalTitle,
                   overview: data.overview ?? "",
                   posterPath: "",
                   mediaType: .movie,
                   genreIDS: [],
                   popularity: 0.0,
                   releaseDate: data.reliseData,
                   video: false,
                   voteAverage: data.voteAverage,
                   voteCount: 0,
                   name: data.title,
                   originalName: data.originalTitle,
                   firstAirDate: data.reliseData,
                   originCountry: [])
        }()
        detailVC.detailData = dataModify
        navigationController?.pushViewController(detailVC, animated: true)
    }

}
//MARK: -  Reload favoriteTableView when click on Favorite tabBar
extension FavoritsViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            loadData()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension FavoritsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesTableCell", for: indexPath) as? MovieTableViewCell else {return UITableViewCell()}
        let item = myData[indexPath.row]
        cell.configure(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetail(for: myData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataController.shared.deleteFromDB(movie: myData[indexPath.row])
            myData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        AnimationTableView().cell(cell, forRowAt: indexPath)
    }
    
}
