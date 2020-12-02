//
//  ReportViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {
    
    private let currentUserID:String
    private let reportUserID:String
    private let reportView = ReportView()
    let isFriend: Bool
    
    init(currentUserID: String, reportUserID: String, isFriend: Bool) {
        self.isFriend = isFriend
        self.currentUserID = currentUserID
        self.reportUserID = reportUserID
        
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
}

extension ReportViewController {
    private func setup() {
        navigationItem.title = "Жалоба"
        view.backgroundColor = .myWhiteColor()
        reportView.delegate = self
    }
    
    private func setupConstraints() {
        view.addSubview(reportView)
        reportView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            reportView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            reportView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            reportView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            reportView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}

extension ReportViewController: ReportViewDelegate {
    
    func reportToFriend() -> Bool {
        isFriend
    }
    
    func sendReportTapped() {
        let reportData = reportView.getData()
        print("Sended \(reportData.reportType) with text \(reportData.text)")
    }

}
