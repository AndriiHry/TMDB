//
//  SecondViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit

class FavoritsViewController: UIViewController {

    @IBOutlet var favoriteTableView: UITableView!
    
    var myData:[Result] = []
    let netwotkController = NetworkController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        favoriteTableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoritesTableCell")
        
        loadData()
    }

    
    
    private func loadData() {
        Task.init {
            do {
                self.myData = try await netwotkController.loadPage(page: 8)
                self.favoriteTableView.reloadData()
            } catch {
                print("Error load data\(error)")
            }
        }
    }
    
    // Setup Detail VC
    func showDetail(for data:Result) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.overview = data.overview
        detailVC.favorTitle = data.nameTitle
        navigationController?.pushViewController(detailVC, animated: true)
    }

}
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
            myData.remove(at: indexPath.row)
            // func delete from DB
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 1, y: 0.5)
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
    

