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
    
        self.recordEntity = ELUser.recordEntity()
        self.title = "Users"
    }
    
    override func viewDidLoad() {
                
        super.viewDidLoad()
        
    }
    
    @IBAction func addUserButtonActivated(_ sender: Any) {
        
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
    
    @IBAction func deleteUserButtonActivated(_ sender: Any) {
    }
    
    @IBAction func searchFieldActivated(_ sender: Any) {
        let templateString = searchField.stringValue
        
        if(templateString.isEmpty == true) {
            recordsArrayController.filterPredicate = nil
            return
        }
        
        recordsArrayController.filterPredicate = NSPredicate(block: { (object, bindings) -> Bool in
            
            let user = object as! ELUser
            
            for (_, value) in user.properties.dictionaryRepresentation() { // why the fuck should I use the NSDictionary representation to enumerate when ELProperties is <NSFastEnumeration> compatible???
                
                if let valueAsString = value as? String {
                    if(valueAsString.range(of: templateString, options: .caseInsensitive) != nil) {
                        return true
                    }
                }
            }
            
            return false
        })
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
