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
    
    let server: ELServer?
    
    required init?(coder: NSCoder) {
        
        self.server = nil
        
        super.init(coder: coder)
    }
    
    init(server: ELServer) {
        
        self.server = server
        
        super.init(nibName:"UsersViewController", bundle:nil)!
    
        self.title = "Users"
    }
    
    override func viewDidLoad() {
        
        server?.getAllRecords(withEntity: ELUser.recordEntity()) { (users, error) in
            if let users = users {
                self.usersArrayController.content = NSMutableArray.init(array: users)
                
                // NOTE: we should lock user edits until all user properties are cached
                for user in users {
                    self.server?.getUpdatedRecord(user, completionBlock: { (updatedUser, error) in
                        if(updatedUser == users.last) {
                            // we can now unlock user edits
                        }
                    })
                }
            }
            else if let error = error {
                let alert = NSAlert(error: error)
                alert.beginSheetModal(for: self.view.window!, completionHandler: { (response) in
                    // don't don anything
                })
            }
        }
        
        super.viewDidLoad()
        
    }
    
    @IBAction func addUserButtonActivated(_ sender: Any) {
        
        if let defaultUserPoperties = ELRecordProperties(dictionary: ["shortname" : "newuser",
                                                                   "principalName" : "new.user@eu.example.com",
                                                                   "email" : "new.user@example.com",
                                                                   "givenName" : "New",
                                                                   "surname" : "User",
                                                                   "fullName" : "User, the last of them",
                                                                   "lockedtime": "ISO TIME STAMP // What is this??", // I do not understand what's this
            "authMethods": [
                "cleartext": "cleartext password",
            ]
            ], mapping: nil) {
            
            let createEditorVC = UserCreateEditorViewController(server:server!, userProperties: defaultUserPoperties)
            createEditorVC.delegate = self;
            self.presentViewControllerAsSheet(createEditorVC)
        }
    }
    
    @IBAction func deleteUserButtonActivated(_ sender: Any) {
    }
}

extension UsersViewController : RecordCreateEditorViewControllerDelegate
{
    func createEditorViewController(_ viewController: UserCreateEditorViewController, didCreateRecord record: ELRecord) {
        self.usersArrayController.addObject(record)
        self.tableView.scrollRowToVisible(self.tableView.selectedRow)
    }
    
    func createEditorViewController(_ viewController: UserCreateEditorViewController, didFailCreatingRecord error: Error?) {
        // see later
    }
}
