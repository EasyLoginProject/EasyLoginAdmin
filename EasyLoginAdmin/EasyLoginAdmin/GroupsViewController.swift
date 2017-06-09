//
//  GroupsViewController.swift
//  EasyLoginAdmin
//
//  Created by Aurélien Hugelé on 09/06/2017.
//  Copyright © 2017 GroundControl. All rights reserved.
//

import Cocoa

class GroupsViewController: NSViewController {
    
    let webServiceConnector: ELWebServiceConnector?
    
    required init?(coder: NSCoder) {
        
        self.webServiceConnector = nil
        
        super.init(coder: coder)
    }
    
    init(webServiceConnector: ELWebServiceConnector?) {
        
        self.webServiceConnector = webServiceConnector
        
        super.init(nibName:"GroupsViewController", bundle:nil)!
        
        self.title = "Groups"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
