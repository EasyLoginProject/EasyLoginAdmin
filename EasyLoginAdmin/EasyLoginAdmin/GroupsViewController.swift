//
//  GroupsViewController.swift
//  EasyLoginAdmin
//
//  Created by Aurélien Hugelé on 09/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

import Cocoa

class GroupsViewController: NSViewController {
    
    let server: ELServer?
    
    required init?(coder: NSCoder) {
        
        self.server = nil
        
        super.init(coder: coder)
    }
    
    init(server: ELServer) {
        
        self.server = server
        
        super.init(nibName:"GroupsViewController", bundle:nil)!
        
        self.title = "Groups"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
