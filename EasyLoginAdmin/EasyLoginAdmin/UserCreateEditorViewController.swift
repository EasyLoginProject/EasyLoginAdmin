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
    
    @IBOutlet weak var tabView: NSTabView!
    
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
    open var delegate: RecordCreateEditorViewControllerDelegate?
    
    @objc dynamic var informationIsValid = false
    var fullNameWasUserEdited = false
    
    required init?(coder: NSCoder) {
        
        self.properties = nil
        self.server = nil
        
        super.init(coder: coder)
    }
    
    convenience init(server: ELServer, userProperties: ELRecordProperties) {
        
        self.init(server: server, userProperties: userProperties, nibName: "UserCreateEditorViewController")
    }
    
    init(server: ELServer, userProperties: ELRecordProperties, nibName: String?) {
        
        self.server = server
        self.properties = userProperties.copy() as? ELRecordProperties // must be copied since may be changed through bindings
        
        super.init(nibName: nibName, bundle: nil)!
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.view.window?.minSize = self.view.frame.size
    }
    
    // MARK: - Actions
    
    @IBAction open func okButtonActivated(_ sender: Any) {
        if(self.commitEditing()) {
            progressIndicator.startAnimation(self)
            
            //at this time the email field is a compulsory to create a user. Use the principalName value and duplicate it as email
            if(properties?.value(forKey: kELUserEmailKey) == nil) {
                properties?.setValue(properties?.value(forKey: kELUserPrincipalNameKey), forKey: kELUserEmailKey)
            }
            properties?.setValue([kELRecordAuthenticationMethodClearTextKey: passwordTextField.stringValue], forKey: kELRecordAuthenticationMethodsKey)
          
            performCore()
        }
    }
    
    @IBAction open func cancelButtonActivated(_ sender: Any) {
        self.dismissViewController(self)
    }
    
    //MARK: - Made to be overriden
    
    open func performCore() { // typically overriden by subclasses to edit an existing user instead of create a new user
        server?.createNewRecord(withEntityClass: ELUser.self, properties: properties!, completionBlock: { (user, error) in
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
        })
    }
}

extension UserCreateEditorViewController : NSTextFieldDelegate
{
    override func controlTextDidChange(_ obj: Notification) {
        // MARK: NOTE: are all fields compulsory -> YES
        // MARK: NOTE: minimum char count for password?
        
        let sender: NSTextField = obj.object as! NSTextField
        
        if(sender == fullNameTextField) {
            fullNameWasUserEdited = fullNameTextField.stringValue.isEmpty ? false : true // reset automatic filling on clear
        }
        else if(fullNameWasUserEdited == false && (sender == givenNameTextField || sender == surnameTextField)) {
            fullNameTextField.stringValue = givenNameTextField.stringValue + " " + surnameTextField.stringValue
        }

        self.informationIsValid = validateInformation()
    }
    
    func validateInformation() -> Bool
    {
        return givenNameTextField.stringValue.characters.count > 0 && surnameTextField.stringValue.characters.count > 0 && fullNameTextField.stringValue.characters.count > 0 && principalNameTextField.stringValue.characters.count > 0 && shortNameTextField.stringValue.characters.count > 0 && passwordTextField.stringValue.characters.count > 0 && passwordVerifyTextField.stringValue.characters.count > 0 && (passwordTextField.stringValue == passwordVerifyTextField.stringValue)
    }
}
