//
//  ReviewTableViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 13.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var reviewCollectionView: UICollectionView!
    
    var reviews = [Review]() {
        didSet {
            self.reviewCollectionView.reloadData()
        }
    }
    
    func updateData(reviews: [Review]) {
        self.reviews = reviews
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.reviewCollectionView.dataSource = self
        self.reviewCollectionView.delegate = self
    }
    
    override func layoutSubviews() {
    }
}

extension ReviewTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCollectionViewCell", for: indexPath) as?
            ReviewCollectionViewCell {
            
            cell.contentView.frame = cell.bounds
            cell.updateView(review: self.reviews[indexPath.row], animated: true)
            
            return cell
        } else {
            return ReviewCollectionViewCell()
        }
    }
    
}

