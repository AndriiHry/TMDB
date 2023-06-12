//
//  DetailViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit

class DetailViewController: UIViewController {
        
    @IBOutlet var detailTextView: UITextView!
    var overview = ""
    var favorTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = favorTitle
        navigationController?.isNavigationBarHidden = false
        navigationItem.largeTitleDisplayMode = .never
        detailTextView.text = overview
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    
}
