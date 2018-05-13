//
//  FriendsCollectionTableViewCell.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 10.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            print("-- FriendsTableViewCell - collectionView didSet")
            // collectionView.dataSource = self
        }
    }
    
    var friends = [Friends]()

    /*
    var mutualFriends = [String:String]() {
        didSet {
            print("-- FriendsTableViewCell - mutualFriends didSet")
        }
    }
    
    func updateData(mutualFriends: [String:String]) {
        print("-- FriendsTableViewCell - updateData")
        self.mutualFriends = mutualFriends
    }
    */
    
    func updateData(friends: [Friends]) {
        self.friends = friends
        // print("-- FriendsTableViewCell - updateData")
        self.collectionView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("-- FriendsTableViewCell - awake From Nib")
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
}

extension FriendsTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendsCollectionViewCell", for: indexPath) as?
            FriendsCollectionViewCell {
            // let imageURL = Array(self.mutualFriends.keys)[indexPath.row]
            // let name = Array(self.mutualFriends.values)[indexPath.row]
            cell.contentView.frame = cell.bounds
            // cell.updateView(imageURL: imageURL, name: name, animated: true)
            cell.setupView(friend: self.friends[indexPath.row])
            // cell.updateView(for: indexPath.row, imageURL: imageURL, name: name)
            return cell
        } else {
            return FriendsCollectionViewCell()
        }
    }
}
