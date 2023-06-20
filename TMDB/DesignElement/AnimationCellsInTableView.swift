//
//  AnimationCellsInTableView.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 20.06.2023.
//

import UIKit

class AnimationTableView {
    
    func cell(_ cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 1, y: 0.25)
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
