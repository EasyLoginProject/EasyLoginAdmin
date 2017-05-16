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
    
    var webServiceConnector: ELWebServiceConnector?
    
    
    required init?(coder: NSCoder) {
        self.webServiceConnector = ELWebServiceConnector(baseURL:URL(string:"http://easylogin.imoof.com:9789/whatever/v1/")!, headers: nil)
        
        super.init(coder:coder)
    }
    
    override func viewDidLoad() {
        
        if let op = webServiceConnector?.getUserPropertiesOperation(forUserUniqueId: "2e88e5f2d5c748bbb839124f5ab3da24", completionBlock: { (userProperties: [String : Any]?, operation: CFXNetworkOperation) in
            if let userProperties = userProperties {
                print(userProperties);
            }
        }) {
            webServiceConnector?.enqueue(op)
        }
        
        super.viewDidLoad()
        
    }
}
