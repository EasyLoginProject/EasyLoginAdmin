//
//  BasicViewControllerProtocol.swift
//  EasyLoginAdmin
//
//  Created by Aurélien Hugelé on 23/06/2017.
//  Copyright © 2017 GroundControl. All rights reserved.
//

import Foundation


class RecordsViewController : NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var recordsArrayController: NSArrayController!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var searchFieldTrailingContstraint: NSLayoutConstraint!
    
    let server: ELServer?

    open var recordClass: AnyClass = ELRecord.self
    
    required init?(coder: NSCoder) {
        
        self.server = nil
        
        super.init(coder: coder)
    }
    
    init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, server: ELServer) {
        self.server = server
        
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)!
        
        self.title = "Records"
    }
    
    override func viewDidLoad() {
        
        searchFieldTrailingContstraint.constant = 6;
        
        self.fetchAllRecords(entityClass: recordClass) { (records, error) in
            if let records = records {
                self.recordsArrayController.content = NSMutableArray(array: records) // we specifically need a NSMutableArray for Cocoa Bindings
            }
            else if let error = error {
                let alert = NSAlert(error: error)
                alert.beginSheetModal(for: self.view.window!, completionHandler: { (response) in
                    // don't do anything
                })
            }
        }
    }
    
    func fetchAllRecords(entityClass: AnyClass, completionBlock: (([ELRecord]?, Error?) -> Swift.Void)? = nil) {
    
        searchFieldTrailingContstraint.constant = 30;
        progressIndicator.startAnimation(self)
        server?.getAllRecords(withEntityClass: entityClass as! ELRecordProtocol.Type, completionBlock: { (records, error) in
        //server?.getAllRecords(entityClass: entityClass, completionBlock: { (records, error) in
            // NOTE: we should lock record edits until all record properties are cached
            if let records = records {
                for record in records {
                    self.server?.getUpdatedRecord(record, completionBlock: { (updatedRecord, error) in
                        if(updatedRecord == records.last) {
                            self.searchFieldTrailingContstraint.constant = 6;
                            self.progressIndicator.stopAnimation(self)
                            
                            completionBlock?(records, nil)
                        }
                    })
                }
            }
            else {
                self.searchFieldTrailingContstraint.constant = 6;
                self.progressIndicator.stopAnimation(self)

                completionBlock?(nil, error)
            }
        })
    }
    
    // MARK: - Actions
    
    @IBAction func tableViewDoubleClickActivated(_ sender: Any) {
        // NOTE: we should lock record edits until all record properties are cached
    }

    
    @IBAction func addRecordButtonActivated(_ sender: Any) {
        
    }
    
    @IBAction func deleteRecordButtonActivated(_ sender: Any) {
        
        if let recordToDelete = recordsArrayController.selectedObjects.last as! ELRecord? {
            self.server?.delete(recordToDelete, completionBlock: { (record, error) in
                if(record != nil) {
                    self.recordsArrayController.removeObject(recordToDelete as Any)
                }
            })
        }
    }
    
    @IBAction func searchFieldActivated(_ sender: Any) {
        let templateString = searchField.stringValue
        
        if(templateString.isEmpty == true) {
            recordsArrayController.filterPredicate = nil
            return
        }
        
        recordsArrayController.filterPredicate = NSPredicate(block: { (object, bindings) -> Bool in
            
            let record = object as! ELRecord
            
            for (_, value) in record.properties.dictionaryRepresentation() { // why the fuck should I use the NSDictionary representation to enumerate when ELProperties is <NSFastEnumeration> compatible???
                
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
