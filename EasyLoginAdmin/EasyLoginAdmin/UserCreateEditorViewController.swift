//
//  UserCreateEditorViewController.swift
//  EasyLoginAdmin
//
//  Created by Aurélien Hugelé on 19/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

import Cocoa

protocol RecordCreateEditorViewControllerDelegate {
    func createEditorViewController(_ viewController: UserCreateEditorViewController, didCreateRecord record: ELRecord)
    func createEditorViewController(_ viewController: UserCreateEditorViewController, didFailCreatingRecord error: Error?)
}

class UserCreateEditorViewController: NSViewController {
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var properties: ELRecordProperties?
    var server: ELServer?
    var delegate: RecordCreateEditorViewControllerDelegate?
    
    required init?(coder: NSCoder) {
        
        self.properties = nil
        self.server = nil
        
        super.init(coder: coder)
    }
    
    init(server: ELServer, userProperties: ELRecordProperties) {
        
        self.server = server
        self.properties = userProperties
        
        super.init(nibName: "UserCreateEditorViewController", bundle: nil)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.view.window?.minSize = self.view.frame.size
    }
    
    // MARK: - Actions
    
    @IBAction func okButtonActivated(_ sender: Any) {
        if(self.commitEditing()) {
            progressIndicator.startAnimation(self)
            
            server?.createNewRecord(withEntity: ELUser.recordEntity(), properties: properties!) { (user, error) in
                
                self.progressIndicator.stopAnimation(self)
                if let user = user {
                    self.delegate?.createEditorViewController(self, didCreateRecord: user);
                    self.dismissViewController(self)
                }
                else if let error = error {
                    let alert = NSAlert(error: error)
                    alert.beginSheetModal(for: self.view.window!, completionHandler: { (response) in
                      self.delegate?.createEditorViewController(self, didFailCreatingRecord: error)
                    })
                }
            }
        }
    }
    
    @IBAction func cancelButtonActivated(_ sender: Any) {
        self.dismissViewController(self)
    }
}
