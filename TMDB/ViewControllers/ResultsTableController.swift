//
//  ResultsViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 11.06.2023.
//

import UIKit

class ResultsTableController: UITableViewController {
    
    @IBOutlet var tableViewSearchResult: UITableView!
    
    var searchData:[Result] = []
    
}

//: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching
extension ResultsTableController: UITableViewDataSourcePrefetching {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewSearchResult.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let item = searchData[indexPath.row]
        cell.textLabel?.text = item.nameTitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.overview = searchData[indexPath.row].overview
        detailVC.favorTitle = searchData[indexPath.row].nameTitle
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        return
    }
    
    
}
