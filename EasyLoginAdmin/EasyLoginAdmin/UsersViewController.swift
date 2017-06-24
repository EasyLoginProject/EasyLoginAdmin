//
//  UsersViewController.swift
//  EasyLoginAdmin
//
//  Created by Aurélien Hugelé on 08/05/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

import Cocoa

class UsersViewController: RecordsViewController {
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    init(server: ELServer) {
        
        super.init(nibName:"UsersViewController", bundle:nil, server:server)!
    
        self.recordClass = ELUser.self
        self.title = "Users"
    }
    
    override func viewDidLoad() {
                
        super.viewDidLoad()
        
    }
    
    @IBAction override func addRecordButtonActivated(_ sender: Any) {
        
        if let defaultUserPoperties = ELRecordProperties(dictionary: [
                                                                   "principalName" : "new.user@eu.example.com",
            "authMethods": [
                "cleartext": "cleartext password",
            ]
            ], mapping: nil) {
            
            let createEditorVC = UserCreateEditorViewController(server:server!, userProperties: defaultUserPoperties)
            createEditorVC.delegate = self;
            self.presentViewControllerAsSheet(createEditorVC)
        }
    }
    
    @IBAction override func deleteRecordButtonActivated(_ sender: Any) {
    }
    
}

extension UsersViewController : RecordCreateEditorViewControllerDelegate
{
    func createEditorViewController(_ viewController: UserCreateEditorViewController, didCreateRecord record: ELRecord) {
        self.recordsArrayController.addObject(record)
        self.tableView.scrollRowToVisible(self.tableView.selectedRow)
    }
    
    func createEditorViewController(_ viewController: UserCreateEditorViewController, didFailCreatingRecord error: Error?) {
        // see later
    }
}
