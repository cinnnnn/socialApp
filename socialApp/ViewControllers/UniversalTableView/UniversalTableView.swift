//
//  UniversalTableView.swift
//  socialApp
//
//  Created by Денис Щиголев on 04.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth
import AuthenticationServices

class UniversalTableView: UITableViewController  {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        tableView.backgroundColor = .myWhiteColor()
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.register(UniversalButtonCell.self, forCellReuseIdentifier: UniversalButtonCell.reuseID)
        tableView.register(UniversallSwitchCell.self, forCellReuseIdentifier: UniversallSwitchCell.reuseID)
        tableView.register(UniversalInfoCell.self, forCellReuseIdentifier: UniversalInfoCell.reuseID)
    }
    
}

