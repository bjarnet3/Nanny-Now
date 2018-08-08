//
//  SubSettingsViewController.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 14.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class SubSettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var settings = [Settings]()
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settings = LocalService.instance.getSubSettings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
