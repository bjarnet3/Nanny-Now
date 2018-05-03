//
//  MessageDetailVC.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 29.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class MessageDetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var adminImageView: UIImageView!
    @IBOutlet weak var guestImageView: UIImageView!
    
    private var adminUser: User?
    private var guestUser: User?
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: { ()
            print("dismissed MessageDetailVC")
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.adminImageView.loadImageUsingCacheWith(urlString: (adminUser?.imageName)!)
        self.guestImageView.loadImageUsingCacheWith(urlString: (guestUser?.imageName)!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    
    func initWith(adminUser: User, guestUser: User) {
        self.adminUser = adminUser
        self.guestUser = guestUser
    }
    
}

extension MessageDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
