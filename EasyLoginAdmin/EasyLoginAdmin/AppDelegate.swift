//
//  AppDelegate.swift
//  EasyLoginAdmin
//
//  Created by Aurélien Hugelé on 03/05/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

import Cocoa

let baseURLString = "http://develop.eu.easylogin.cloud"  //"http://easylogin.imoof.com:9789/whatever/v1/"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    var windowController : NSWindowController!
    var mainViewController : MainViewController!
    var mainTabViewController : NSTabViewController!
    var usersViewController : UsersViewController!
    var groupsViewController : GroupsViewController! 
    
    var server : ELServer!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    
        server = ELServer(baseURL: URL(string:baseURLString)!)
    
        self.setupMainUI()
        windowController.window?.makeKeyAndOrderFront(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func setupMainUI() {
        
        windowController = NSWindowController(window: window)
        
        mainViewController = MainViewController();
        mainTabViewController = NSTabViewController()
        mainTabViewController.view.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        mainTabViewController.view.frame = mainViewController.view.bounds
        mainViewController.view.addSubview(mainTabViewController.view)
        
        usersViewController = UsersViewController(server: server)
        groupsViewController = GroupsViewController(server: server)
        
        mainTabViewController.addChildViewController(usersViewController)
        mainTabViewController.addChildViewController(groupsViewController)
        
        windowController.contentViewController = mainViewController
    }
}

