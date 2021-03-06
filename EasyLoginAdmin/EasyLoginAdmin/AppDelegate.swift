//
//  AppDelegate.swift
//  EasyLoginAdmin
//
//  Created by Aurélien Hugelé on 03/05/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

import Cocoa

let baseURLString = /*"http://develop.eu.easylogin.cloud"*/ "https://demo.eu.easylogin.cloud"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    var windowController : NSWindowController!
    var mainViewController : MainViewController!
    var mainTabViewController : NSTabViewController!
    var usersViewController : UsersViewController!
    var devicesViewController : DevicesViewController!
    
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
        mainTabViewController.transitionOptions = .allowUserInteraction
        mainViewController.view.addSubview(mainTabViewController.view)
        
        usersViewController = UsersViewController(server: server)
        devicesViewController = DevicesViewController(server: server)
        
        mainTabViewController.addChildViewController(usersViewController)
        mainTabViewController.addChildViewController(devicesViewController)
        //mainTabViewController.addChildViewController(groupsViewController)
        
        windowController.contentViewController = mainViewController
    }
}

