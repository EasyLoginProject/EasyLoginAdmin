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
    
    let server: ELServer?
    open var recordEntity = "ELRecord"
    
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
        self.fetchAllRecords(entity: self.recordEntity) { (records, error) in
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
    
    func fetchAllRecords(entity: String, completionBlock: (([ELRecord]?, Error?) -> Swift.Void)? = nil) {
    
        server?.getAllRecords(withEntity: entity, completionBlock: { (records, error) in
            // NOTE: we should lock record edits until all record properties are cached
            if let records = records {
                for record in records {
                    self.server?.getUpdatedRecord(record, completionBlock: { (updatedRecord, error) in
                        if(updatedRecord == records.last) {
                            completionBlock?(records, nil)
                        }
                    })
                }
            }
            else {
                completionBlock?(nil, error)
            }
        })
    }
    
    @IBAction func addRecordButtonActivated(_ sender: Any) {
        
    }
    
    @IBAction func deleteRecordButtonActivated(_ sender: Any) {
        
    }
}
