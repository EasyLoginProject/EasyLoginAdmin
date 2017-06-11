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
        
//        if let op = webServiceConnector?.getUserPropertiesOperation(forUserIdentifier: "5d30d66df8414c2daf04ba70a654edc6", completionBlock: { (userProperties: [String : Any]?, operation: CFXNetworkOperation) in
//            if let userProperties = userProperties {
//                print(userProperties);
//            }
//        }) {
//            webServiceConnector?.enqueue(op)
//        }
        
        if let op = webServiceConnector?.getAllUsersOperation(completionBlock: { (users, op) in
            if let users = users {
                self.usersArrayController.content = NSMutableArray.init(array: users)
                
                
                // NOTE: we should block user edits until all user properties are cached
                let parallelWSC = self.webServiceConnector?.copy() as! ELWebServiceConnector
                parallelWSC.maxConcurrentOperationCount = 10;
                
                for user in users {
                    let op = parallelWSC.getUserPropertiesOperation(forUserIdentifier: user.identifier(), completionBlock: { (userProperties, op) in
                        if let userProperties = userProperties {
                            print(userProperties);
                            if let recordProperties = ELRecordProperties(dictionary: userProperties, mapping: nil) {
                                #if USE_OBJC_PROPERTIES
                                user.__transfer(from: recordProperties)
                                #else
                                user.update(with: recordProperties, deletes: true)
                                #endif
                            }
                        }
                    })
                    
                        parallelWSC.enqueue(op)
                }
            }
        }) {
            webServiceConnector?.enqueue(op)
        }
        
        super.viewDidLoad()
        
    }
    
    @IBAction func addUserButtonActivated(_ sender: Any) {
        
        if let op = webServiceConnector?.createNewUserOperation(with: ["shortname" : "newuser",
                                                                       "principalName" : "new.user@eu.example.com",
                                                                       "email" : "new.user@example.com",
                                                                       "givenName" : "New",
                                                                       "surname" : "User",
                                                                       "fullName" : "User, the last of them",
                                                                       "lockedtime": "ISO TIME STAMP // What is this??", // I do now understand what's this
                                                                       "authMethods": [
                                                                         "cleartext": "cleartext password",
                                                                       ]
                                                                      ],
                                                                completionBlock: { (user, op) in
            if let user = user {
                self.usersArrayController.addObject(user)
            }
        }) {
            webServiceConnector?.enqueue(op)
        }
    }
    
    @IBAction func deleteUserButtonActivated(_ sender: Any) {
    }
}
