//
//  ResultsViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 11.06.2023.
//

import UIKit

class ResultsTableController: UITableViewController {
    
    @IBOutlet var tableViewSearchResult: UITableView!

    let netwotkController = NetworkController()
    var parentNavigationController: UINavigationController?
    var resultDidSelected: ResultSelected?
    
    var searchData:[Result] = []
    typealias ResultSelected = (Result) -> ()
    let identifyResultCell: String = "ResultTableViewCell"
    let identifyDetailVC: String = "DetailViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSearchResult.register(UINib(nibName: identifyResultCell, bundle: nil), forCellReuseIdentifier: identifyResultCell)
    }
    
}
// MARK: - End Class

//MARK: - UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching
extension ResultsTableController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableViewSearchResult.dequeueReusableCell(withIdentifier: "ResultsTableViewCell", for: indexPath) as? ResultTableViewCell else {return UITableViewCell()}
        let item = searchData[indexPath.row]
        cell.configureSearchResults(item: item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchData[indexPath.row]
        resultDidSelected?(result)
    }


}
