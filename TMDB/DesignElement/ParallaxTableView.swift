//
//  ParallaxTableView.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 10.06.2023.
//

import UIKit

class ParallaxTableView: UITableView {

    var height: NSLayoutConstraint?
    var bottom: NSLayoutConstraint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let header = tableHeaderView else {return}
        if let imageView = header.subviews.first as? UIImageView {
            height = imageView.constraints.filter{$0.identifier == "height"}.first
            bottom = header.constraints.filter{$0.identifier == "bottom"}.first
        }
        
        let offsetY = contentOffset.y
//        let originalHeight = header.bounds.height
//        let minHeight: CGFloat = 150
//        if offsetY < 0 {
//            height?.constant = max(originalHeight - offsetY, originalHeight + offsetY/2)
//            bottom?.constant = offsetY / 2
//        } else {
//            height?.constant = max(minHeight, originalHeight - offsetY)
//            bottom?.constant = 0
//        }
        
        bottom?.constant = offsetY >= 0 ? 0 : offsetY / 2
        height?.constant = max(header.bounds.height - offsetY, header.bounds.height + offsetY/2)
        header.clipsToBounds = offsetY <= 0
    }

}
