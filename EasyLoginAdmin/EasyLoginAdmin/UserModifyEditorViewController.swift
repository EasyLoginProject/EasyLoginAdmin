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


class UserModifyEditorViewController: UserCreateEditorViewController, UserPasswordEditorViewControllerDelegate {
    @IBOutlet weak var imageView: NSImageView!
    
    @IBOutlet weak var changePasswordCheckImageView: NSImageView!
    
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
            performCore()
        }
    }
    
    
    @IBAction func changePasswordButtonActivated(_ sender: Any) {
        
        let passwordEditorVC = UserPasswordEditorViewController(server: server!, record: record!)
        passwordEditorVC.delegate = self
        
        changePasswordCheckImageView.isHidden = true
        
        self.presentViewControllerAsSheet(passwordEditorVC)
    }
    
    //MARK: - Made to be overriden
    
    override func performCore() { // typically overriden by subclasses to edit an existing user instead of create a new user
        if let updatedProperties: ELRecordProperties = self.record?.properties.difference(with: self.properties!, deletes: true) {// we want to extract only the updated properties. Because we *copied* the record properties on init, we should be able to diff despite using Cocoa Bindings...
            server?.update(self.record!, withUpdatedProperties: updatedProperties, completionBlock: { (updatedRecord, error) in
                self.progressIndicator.stopAnimation(self)
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
    }
    
    
    // MARK: - Delegates
    
    func userPasswordEditorViewController(_ viewController: UserPasswordEditorViewController, didModifyPasswordForRecord record: ELRecord) {
        self.changePasswordInformationIsValid = true
        changePasswordCheckImageView.isHidden = false
        dismissViewController(viewController)
    }
    
    func userPasswordEditorViewController(_ viewController: UserPasswordEditorViewController, didCancelModifyingPasswordForRecord record: ELRecord) {
        self.changePasswordInformationIsValid = false
        dismissViewController(viewController)
    }
    
    func userPasswordEditorViewController(_ viewController: UserPasswordEditorViewController, didFailModifyingPasswordForRecord record: ELRecord, error: Error?) {
        self.changePasswordInformationIsValid = false
        changePasswordCheckImageView.isHidden = true
        dismissViewController(viewController)
    }
    
    
    // MARK: - Private
    
    override func validateInformation() -> Bool
    {
        return givenNameTextField.stringValue.characters.count > 0 && surnameTextField.stringValue.characters.count > 0 && fullNameTextField.stringValue.characters.count > 0 && principalNameTextField.stringValue.characters.count > 0 && shortNameTextField.stringValue.characters.count > 0
    }
}
