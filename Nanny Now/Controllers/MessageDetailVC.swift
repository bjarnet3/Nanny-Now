//
//  MessageDetailVC.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 04.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import SwiftKeychainWrapper

class MessageDetailVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var user: User?
    var remoteUser: User?
    
    var messages = [Message]()
    var totalMessages: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        observeMessages()
    }
    
    func setupView(user:User, remoteUser: User) {
        self.user = user
        self.remoteUser = remoteUser
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Observer, Firebase Database Functions
    // ----------------------------------------
    func observeMessages() {
        if let UID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            DataService.instance.REF_MESSAGES.child("private").child(UID).child("all").queryOrdered(byChild: "messageTime").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapValue = snapshot.value as? Dictionary<String, AnyObject> {
                    self.totalMessages = snapValue.keys.count
                    
                    print("snapshot count: \(snapValue.keys.count)")
                    print("------------------")
                    
                    for (_,value) in snapValue {
                        if let snapMessage = value as? [String:AnyObject] {
                            
                            guard let userID = self.user?.userUID else { return }
                            guard let remoteID = self.remoteUser?.userUID else { return }
                            
                            if userID != remoteID {
                                if let firstUID = snapMessage["fromUID"] as? String, firstUID == userID || firstUID == remoteID {
                                    if let secondUID = snapMessage["toUID"] as? String, secondUID == userID || secondUID == remoteID {
                                        if firstUID != secondUID {
                                            if firstUID == userID {
                                                self.fetchMessageObserver(snapMessage, remoteUID: userID, userUID: remoteID)
                                            } else if firstUID == remoteID {
                                                self.fetchMessageObserver(snapMessage, remoteUID: remoteID, userUID: userID)
                                            }
                                        }
                                    }
                                }
                            } else {
                                if let firstUID = snapMessage["fromUID"] as? String, firstUID == userID {
                                    if let secondUID = snapMessage["toUID"] as? String, secondUID == remoteID {
                                        self.fetchMessageObserver(snapMessage, remoteUID: remoteID, userUID: userID)
                                    }
                                }
                            }
                            
                        }
                    }
                }
                
            })
        }
    }
    
    func fetchMessageObserver(_ messageSnap: Dictionary<String, AnyObject>, remoteUID: String, userUID: String) {
        let message = Message(
            from: remoteUID,
            to:  userUID,
            messageID: messageSnap["messageID"] as! String,
            message:  messageSnap["message"] as! String,
            messageTime:  messageSnap["messageTime"] as! String,
            highlighted:  messageSnap["highlighted"] as! Bool,
            remoteUID: self.remoteUser?.userUID
            )
        // self.messages.sort(by: { $0._messageTime < $1._messageTime })
        self.messages.append(message)
        self.tableView.reloadData()
    }
    
}

extension MessageDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let user = self.user, messages[indexPath.row]._fromUID == user.userUID {
            if let leftCell = tableView.dequeueReusableCell(withIdentifier: "MessageDetailLeftCell", for: indexPath) as? MessageDetailTableCell {
                print(user.imageName)
                
                leftCell.setupView(with: self.messages[indexPath.row], to: user)
                return leftCell
            }
        } else if let remoteUser = self.remoteUser, messages[indexPath.row]._toUID == remoteUser.userUID {
            print(self.remoteUser?.userUID)
            print(self.remoteUser?.imageName)
            if let rightCell = tableView.dequeueReusableCell(withIdentifier: "MessageDetailRightCell", for: indexPath) as? MessageDetailTableCell {
                
                print(remoteUser.imageName)
                rightCell.setupView(with: self.messages[indexPath.row], to: remoteUser)
                return rightCell
            }
        }
        return MessageDetailTableCell()
    }
    
    
}
