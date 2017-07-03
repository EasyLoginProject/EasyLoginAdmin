//
//  UserModifyEditorViewController.swift
//  EasyLoginAdmin
//
//  Created by Aurélien Hugelé on 26/06/2017.
//  Copyright © 2017 GroundControl. All rights reserved.
//

import Cocoa

protocol UserModifyEditorViewControllerDelegate {
    func modifyEditorViewController(_ viewController: UserModifyEditorViewController, didModifyRecord record: ELRecord)
    func modifyEditorViewController(_ viewController: UserModifyEditorViewController, didFailModifyingRecord error: Error?)
}


class UserModifyEditorViewController: UserCreateEditorViewController {
    @IBOutlet weak var imageView: NSImageView!
    
    @IBOutlet var changePasswordPanel: NSPanel!
    @objc dynamic var changePasswordInformationIsValid = false
    
    //open var delegate: UserModifyEditorViewControllerDelegate? // since I don't know how to handle protocol inheritence is swift, i have to declare another delegate property... sorry
    var delegate_overriden: UserModifyEditorViewControllerDelegate?
    var record: ELRecord?
    
    // MARK: - PUBLIC
    
    required init?(coder: NSCoder) {
        
        self.record = nil
        
        super.init(coder: coder)
    }
    
    init(server: ELServer, record: ELRecord) {
        
        self.record = record
        let tmpProperties = record.properties
        
        super.init(server: server, userProperties: tmpProperties, nibName: "UserModifyEditorViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        fullNameWasUserEdited = (fullNameTextField.stringValue != (givenNameTextField.stringValue + " " + surnameTextField.stringValue))
        
    }
    
    // MARK: - Actions
    
    @IBAction override func okButtonActivated(_ sender: Any) {
        if(self.commitEditing()) {
            progressIndicator.startAnimation(self)
            
            //            //at this time the email field is a compulsory to create a user. Use the principalName value and duplicate it as email
            //            if(properties?.value(forKey: kELUserEmailKey) == nil) {
            //                properties?.setValue(properties?.value(forKey: kELUserPrincipalNameKey), forKey: kELUserEmailKey)
            //            }
            //            properties?.setValue([kELRecordAuthenticationMethodClearTextKey: passwordTextField.stringValue], forKey: kELRecordAuthenticationMethodsKey)
            
            performCore()
        }
    }
    
    
    @IBAction func changePasswordButtonActivated(_ sender: Any) {
        self.tabView.window?.beginSheet(changePasswordPanel, completionHandler: { (response) in
            if(response == NSModalResponseStop) {
                // maybe a specific call instead of using properties?
                //properties?.setValue(passwordTextField, forKey: ....)
                
                // do we want to change the password now or wait for the parent sheet to be closed with the OK button?
            }
            else {
                self.changePasswordInformationIsValid = false
            }
        })
    }
    @IBAction func changePasswordOKButtonActivated(_ sender: Any) {
        self.tabView.window?.endSheet(changePasswordPanel, returnCode: NSModalResponseStop)
    }
    
    @IBAction func changePasswordCancelButtonActivated(_ sender: Any) {
        self.tabView.window?.endSheet(changePasswordPanel, returnCode: NSModalResponseAbort)
    }
    
    //MARK: - Made to be overriden
    
    override func performCore() { // typically overriden by subclasses to edit an existing user instead of create a new user
        if let updatedProperties: ELRecordProperties = self.record?.properties.difference(with: self.properties!, deletes: true) {// we want to extract only the updated properties. Because we *copied* the record properties on init, we should be able to diff despite using Cocoa Bindings...
            server?.update(self.record!, withUpdatedProperties: updatedProperties, completionBlock: { (updatedRecord, error) in
                self.progressIndicator.stopAnimation(self)
                if updatedRecord != nil {
                    if(self.changePasswordInformationIsValid) { // true if password was tried to be changed
                        // currently there is no password change API, use the standard properties update API
//                        self.server?.update(self.record!, withNewPassword: self.passwordTextField.stringValue, usingOldPassword: "old password???", completionBlock: { (updatedRecord, error) in
                        // to change password, update the "authMethods" property with a clear text password
                        self.server?.update(self.record!, withUpdatedProperties: ELRecordProperties(dictionary: [kELRecordAuthenticationMethodsKey : [kELRecordAuthenticationMethodClearTextKey : self.passwordTextField.stringValue]], mapping:nil)!, completionBlock: { (updatedRecord, error) in
                            if updatedRecord != nil {
                                self.delegate_overriden?.modifyEditorViewController(self, didModifyRecord: self.record!);
                                self.dismissViewController(self)
                            }
                            else if let error = error {
                                let alert = NSAlert(error: error)
                                alert.beginSheetModal(for: self.view.window!, completionHandler: { (response) in
                                    self.delegate_overriden?.modifyEditorViewController(self, didFailModifyingRecord: error)
                                })
                            }
                        })
                    }
                    else {
                        self.delegate_overriden?.modifyEditorViewController(self, didModifyRecord: self.record!);
                        self.dismissViewController(self)
                    }
                }
                else if let error = error {
                    let alert = NSAlert(error: error)
                    alert.beginSheetModal(for: self.view.window!, completionHandler: { (response) in
                        self.delegate_overriden?.modifyEditorViewController(self, didFailModifyingRecord: error)
                    })
                }
            })
        }
    }
    
    
    // MARK: - Delegate
    
    override func controlTextDidChange(_ obj: Notification) {
        // MARK: NOTE: minimum char count for password?
        
        super.controlTextDidChange(obj)
        
        //let sender: NSTextField = obj.object as! NSTextField
        
        self.changePasswordInformationIsValid = validateChangePasswordInformation()
    }
    
    // MARK: - Private
    
    override func validateInformation() -> Bool
    {
        return givenNameTextField.stringValue.characters.count > 0 && surnameTextField.stringValue.characters.count > 0 && fullNameTextField.stringValue.characters.count > 0 && principalNameTextField.stringValue.characters.count > 0 && shortNameTextField.stringValue.characters.count > 0 // do not validate password here, use validateChangePasswordInformation() instead
    }
    
    func validateChangePasswordInformation() -> Bool
    {
        return passwordTextField.stringValue.characters.count > 0 && passwordVerifyTextField.stringValue.characters.count > 0 && (passwordTextField.stringValue == passwordVerifyTextField.stringValue)
    }
    
}
