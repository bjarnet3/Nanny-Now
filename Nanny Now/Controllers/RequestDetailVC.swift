//
//  MessageDetailVC.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 29.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class RequestDetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var adminImageView: UIImageView!
    @IBOutlet weak var guestImageView: UIImageView!
    
    private var adminUser: User?
    private var guestUser: User?
    
    private var viewRect = UIScreen.main.bounds
    
    @IBAction func backAction(_ sender: Any) {
        exitDetailView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.adminImageView.loadImageUsingCacheWith(urlString: (adminUser?.imageName)!)
        self.guestImageView.loadImageUsingCacheWith(urlString: (guestUser?.imageName)!)
        
        self.backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.backgroundView.layer.cornerRadius = 22.0
        self.backgroundView.frame = viewRect
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        
        UIView.animate(withDuration: 0.45, delay: 0.150, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
            self.backgroundView.frame = UIScreen.main.bounds
            self.backgroundView.layer.cornerRadius = 0.0
            self.backgroundView.layoutIfNeeded()
        })
        
    }
    
    func exitDetailView() {
        UIView.animate(withDuration: 0.45, delay: 0.010, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
            self.backgroundView.frame = self.viewRect
            self.backgroundView.layer.cornerRadius = 22.0
        }, completion: { (true) in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    func initWith(adminUser: User, guestUser: User, viewRect: CGRect) {
        self.adminUser = adminUser
        self.guestUser = guestUser
        
        self.viewRect = viewRect
    }
    
}

extension RequestDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
