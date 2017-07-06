//
//  UserPasswordEditorViewController.swift
//  EasyLoginAdmin
//
//  Created by Aurélien Hugelé on 06/07/2017.
//  Copyright © 2017 GroundControl. All rights reserved.
//

import Cocoa

protocol UserPasswordEditorViewControllerDelegate {
    func userPasswordEditorViewController(_ viewController: UserPasswordEditorViewController, didModifyPasswordForRecord record: ELRecord)
    func userPasswordEditorViewController(_ viewController: UserPasswordEditorViewController, didCancelModifyingPasswordForRecord record: ELRecord)
    func userPasswordEditorViewController(_ viewController: UserPasswordEditorViewController, didFailModifyingPasswordForRecord record: ELRecord, error: Error?)
}


class UserPasswordEditorViewController: NSViewController {

    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var passwordVerifyTextField: NSSecureTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @objc dynamic var changePasswordInformationIsValid = false
    
    var server: ELServer?
    var record: ELRecord?
    
    var delegate: UserPasswordEditorViewControllerDelegate?

    required init?(coder: NSCoder) {
        
        self.record = nil
        self.server = nil
        
        super.init(coder: coder)
    }
    
    convenience init(server: ELServer, record: ELRecord) {
        
        self.init(server: server, record: record, nibName: "UserPasswordEditorViewController")
    }
    
    init(server: ELServer, record: ELRecord, nibName: String?) {
        
        self.server = server
        self.record = record
        
        super.init(nibName: nibName, bundle: nil)!
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func changePasswordOKButtonActivated(_ sender: Any) {
        
        if(self.commitEditing()) {
            progressIndicator.startAnimation(self)
            performCore()
        }
    }
    
    @IBAction func changePasswordCancelButtonActivated(_ sender: Any) {
        delegate?.userPasswordEditorViewController(self, didCancelModifyingPasswordForRecord: record!)
    }
    
    func performCore() { // typically overriden by subclasses to edit an existing user instead of create a new user
        if(self.changePasswordInformationIsValid) { // true if password was tried to be changed
            // currently there is no password change API, use the standard properties update API
            // to change password, update the "authMethods" property with a clear text password
            self.server?.update(self.record!, withUpdatedProperties: ELRecordProperties(dictionary: [kELRecordAuthenticationMethodsKey : [kELRecordAuthenticationMethodClearTextKey : self.passwordTextField.stringValue]], mapping:nil)!, completionBlock: { (updatedRecord, error) in
                self.progressIndicator.stopAnimation(self)
                if updatedRecord != nil {
                    self.delegate?.userPasswordEditorViewController(self, didModifyPasswordForRecord: self.record!)

                }
                else if let error = error {
                    let alert = NSAlert(error: error)
                    alert.beginSheetModal(for: self.view.window!, completionHandler: { (response) in
                        self.delegate?.userPasswordEditorViewController(self, didFailModifyingPasswordForRecord: self.record!, error: error)
                    })
                }
            })
        }
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        // MARK: NOTE: minimum char count for password?
        
        //let sender: NSTextField = obj.object as! NSTextField
        
        self.changePasswordInformationIsValid = validateChangePasswordInformation()
    }
 
    func validateChangePasswordInformation() -> Bool
    {
                // MARK: NOTE: minimum char count for password?
        
        return passwordTextField.stringValue.characters.count > 0 && passwordVerifyTextField.stringValue.characters.count > 0 && (passwordTextField.stringValue == passwordVerifyTextField.stringValue)
    }
}
