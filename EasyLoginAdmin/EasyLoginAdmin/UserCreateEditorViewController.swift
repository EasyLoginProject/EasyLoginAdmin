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
    
    @IBOutlet weak var givenNameTextField: NSTextField!
    @IBOutlet weak var surnameTextField: NSTextField!
    @IBOutlet weak var fullNameTextField: NSTextField!
    @IBOutlet weak var principalNameTextField: NSTextField!
    @IBOutlet weak var shortNameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var passwordVerifyTextField: NSSecureTextField!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var properties: ELRecordProperties?
    var server: ELServer?
    var delegate: RecordCreateEditorViewControllerDelegate?
    
    @objc dynamic var informationIsValid = false
    
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
                        
            properties?.setValue(["cleartext" : passwordTextField.stringValue], forKey: kELUserAuthenticationMethodsKey)
            
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

extension UserCreateEditorViewController : NSTextFieldDelegate
{
    override func controlTextDidChange(_ obj: Notification) {
        // MARK: NOTE: are all fields compulsory?
        // MARK: NOTE: minimum char count for password?

        self.informationIsValid = givenNameTextField.stringValue.characters.count > 0 && surnameTextField.stringValue.characters.count > 0 && principalNameTextField.stringValue.characters.count > 0 && shortNameTextField.stringValue.characters.count > 0 && passwordTextField.stringValue.characters.count > 0 && passwordVerifyTextField.stringValue.characters.count > 0 && (passwordTextField.stringValue == passwordVerifyTextField.stringValue)
    }
}
