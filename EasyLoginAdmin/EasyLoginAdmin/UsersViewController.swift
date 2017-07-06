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
    
    @IBAction override func tableViewDoubleClickActivated(_ sender: Any) {
        // NOTE: we should lock record edits until all record properties are cached
        
        let arrangedObjects = recordsArrayController.arrangedObjects as! NSArray
        let record = arrangedObjects[tableView.clickedRow] as! ELRecord
        
        if(NSEvent.modifierFlags().contains(NSEventModifierFlags.option)) {
            let userPasswordEditorVC = UserPasswordEditorViewController(server: server!, record: record)
            userPasswordEditorVC.delegate = self
            self.presentViewControllerAsSheet(userPasswordEditorVC)
        }
        else {
            let modifyEditorVC = UserModifyEditorViewController(server:server!, record: record)
            modifyEditorVC.delegate = self;
            modifyEditorVC.delegate_overriden = self; // since I don't know how to handle protocol inheritence is swift, i have to declare another delegate property... sorry
            self.presentViewControllerAsSheet(modifyEditorVC)
        }
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
//    
//    @IBAction override func deleteRecordButtonActivated(_ sender: Any) {
//    }
    
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

extension UsersViewController : UserModifyEditorViewControllerDelegate
{
    func modifyEditorViewController(_ viewController: UserModifyEditorViewController, didModifyRecord record: ELRecord) {
        
        
        let arrangedObjects = self.recordsArrayController.arrangedObjects as! NSArray
        let indexOfUpdatedRecord = arrangedObjects.indexOfObjectIdentical(to: record)
        if(indexOfUpdatedRecord != NSNotFound) {
            self.recordsArrayController.setSelectionIndex(indexOfUpdatedRecord)
            self.tableView.scrollRowToVisible(self.tableView.selectedRow)
        }
    }
    
    func modifyEditorViewController(_ viewController: UserModifyEditorViewController, didFailModifyingRecord error: Error?) {
        // see later
    }
}

extension UsersViewController : UserPasswordEditorViewControllerDelegate
{
    func userPasswordEditorViewController(_ viewController: UserPasswordEditorViewController, didModifyPasswordForRecord record: ELRecord) {
        dismissViewController(viewController)
    }
    
    func userPasswordEditorViewController(_ viewController: UserPasswordEditorViewController, didCancelModifyingPasswordForRecord record: ELRecord) {
        dismissViewController(viewController)
    }
    
    func userPasswordEditorViewController(_ viewController: UserPasswordEditorViewController, didFailModifyingPasswordForRecord record: ELRecord, error: Error?) {
        dismissViewController(viewController)
    }
}

