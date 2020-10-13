//
//  UnterestsSelectionViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth

class InterestsSelectionViewController: UIViewController {
    
    var currentUser: User
    let headerLabel = UILabel(labelText: "Расскажи о своих интересах", textFont: .avenirBold(size: 24),linesCount: 0)
    let 
    
    init(currentUser: User){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupConstraints()
    }
    
    private func setup() {
        
    }
}

extension InterestsSelectionViewController {
    
    private func setupConstraints() {
        
    }
}
