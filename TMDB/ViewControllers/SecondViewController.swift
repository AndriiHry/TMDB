//
//  SecondViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet var favoriteTableView: UITableView!
    
    var myData:[Result] = []
    let netwotkController = NetworkController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteTableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoritesTableCell")
        loadData()
    }

    
    
    private func loadData() {
        Task.init {
            do {
                self.myData += try await netwotkController.loadNextPage()
                self.favoriteTableView.reloadData()
            } catch {
                print(error)
            }
        }
    }

}
extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        return 116
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.overview = myData[indexPath.row].overview
        detailVC.favorTitle = myData[indexPath.row].title
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            myData.remove(at: indexPath.row)
            // func delete from DB
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
}



    

