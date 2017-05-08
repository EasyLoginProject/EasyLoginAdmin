//
//  UsersViewController.swift
//  GroundControlAdmin
//
//  Created by Aurélien Hugelé on 08/05/2017.
//  Copyright © 2017 GroundControl. All rights reserved.
//

import Cocoa

class UsersViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var usersArrayController: NSArrayController!
    
    var webServiceConnector: GCWebServiceConnector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}
