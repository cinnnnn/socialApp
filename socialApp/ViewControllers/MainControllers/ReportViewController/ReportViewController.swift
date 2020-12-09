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
    private let isFriend: Bool
    weak var messageControllerDelegate: MessageControllerDelegate?
    weak var reportDelegate: ReportsListnerDelegate?
    weak var peopleDelegate: PeopleListenerDelegate?
    weak var requestDelegate: RequestChatListenerDelegate?
    
    init(currentUserID: String,
         reportUserID: String,
         isFriend: Bool,
         reportDelegate: ReportsListnerDelegate?,
         peopleDelegate: PeopleListenerDelegate?,
         requestDelegate: RequestChatListenerDelegate?) {
        
        self.isFriend = isFriend
        self.currentUserID = currentUserID
        self.reportUserID = reportUserID
        self.reportDelegate = reportDelegate
        self.peopleDelegate = peopleDelegate
        self.requestDelegate = requestDelegate
        
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reportView.setNeedsLayout()
    }
}

extension ReportViewController {
    private func setup() {
        navigationItem.title = "Жалоба"
        navigationController?.setNavigationBarHidden(false, animated: true)
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
        //setup isInitiateDeleteChat for hide pop up about delete chat
        messageControllerDelegate?.isInitiateDeleteChat = true
        
        let reportData = reportView.getData()
        FirestoreService.shared.addReport(currentUserID: currentUserID,
                                          reportUserID: reportUserID,
                                          typeOfReport: reportData.reportType,
                                          text: reportData.text,
                                          inChat: isFriend) {[weak self] result in
            switch result {
            
            case .success(let report):
                //add report to reportData
                self?.reportDelegate?.reports.append(report)
                //delete from request
                self?.requestDelegate?.deleteRequest(requestID: report.reportUserID)
                //delete from peopleNearby
                self?.peopleDelegate?.deletePeople(peopleID: report.reportUserID)
                //go to rootVC
                self?.navigationController?.popToRootViewController(animated: true)
                PopUpService.shared.showInfo(text: "Жалоба: \(reportData.reportType) отправлена")
            case .failure(let error):
                PopUpService.shared.showInfo(text: "Ошибка: \(error.localizedDescription)")
            }
        }
    }
}
