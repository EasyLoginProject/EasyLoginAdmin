//
//  UsersViewController.swift
//  EasyLoginAdmin
//
//  Created by Aurélien Hugelé on 08/05/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

import Cocoa

class UsersViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var usersArrayController: NSArrayController!
    
    let webServiceConnector: ELWebServiceConnector?
    
    required init?(coder: NSCoder) {
        
        self.webServiceConnector = nil
        
        super.init(coder: coder)
    }
    
    init(webServiceConnector: ELWebServiceConnector?) {
        
        self.webServiceConnector = webServiceConnector
        
        super.init(nibName:"UsersViewController", bundle:nil)!
    
        self.title = "Users"
    }
    
    override func viewDidLoad() {
        
        if let op = webServiceConnector?.getUserPropertiesOperation(forUserUniqueId: "5d30d66df8414c2daf04ba70a654edc6", completionBlock: { (userProperties: [String : Any]?, operation: CFXNetworkOperation) in
            if let userProperties = userProperties {
                print(userProperties);
            }
        }) {
            webServiceConnector?.enqueue(op)
        }
        
        if let op = webServiceConnector?.getAllUsersOperation(completionBlock: { (users, op) in
            if let users = users {
                self.usersArrayController.content = users;
            }
        }) {
            webServiceConnector?.enqueue(op)
        }
        
        super.viewDidLoad()
        
    }
}
