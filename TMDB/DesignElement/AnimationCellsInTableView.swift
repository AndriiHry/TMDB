//
//  AnimationCellsInTableView.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 20.06.2023.
//

import UIKit

class AnimationTableView {
    
    func cell(_ cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.transform = CGAffineTransform(scaleX: 1, y: 0.95)
        cell.alpha = 0.75
        
        UIView.animate(withDuration: 0.5) {
//            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            cell.alpha = 1
        }
    }
    
}
