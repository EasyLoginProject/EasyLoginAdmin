//
//  DevicesViewController.swift
//  EasyLoginAdmin
//
//  Created by Aurélien Hugelé on 23/06/2017.
//  Copyright © 2017 GroundControl. All rights reserved.
//

import Cocoa


class DevicesViewController: RecordsViewController {
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
    
    init(server: ELServer) {
        
        super.init(nibName:"DevicesViewController", bundle:nil, server:server)!
        
        self.recordEntity = ELDevice.recordEntity()
        self.title = "Devices"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
