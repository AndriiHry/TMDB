//
//  FirstViewController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 06.06.2023.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet var mainCollectionView: UICollectionView!
    
    var jsnData:[Result] = []
    let netwotkController = NetworkController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainCollectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MainCollectionCell")
        loadData()
        
    }
    
    private func loadData() {
        Task.init {
            do {
                self.jsnData += try await netwotkController.loadNextPage()
                self.mainCollectionView.reloadData()
            } catch {
                print("Error load data\(error)")
            }
        }
    }
    
    
    
}
extension FirstViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsnData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionCell", for: indexPath) as? MovieCollectionViewCell else { return UICollectionViewCell() }
        let item = jsnData[indexPath.item]
        cell.configure(item: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.overview = jsnData[indexPath.row].overview
        detailVC.favorTitle = jsnData[indexPath.row].nameTitle
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
}
