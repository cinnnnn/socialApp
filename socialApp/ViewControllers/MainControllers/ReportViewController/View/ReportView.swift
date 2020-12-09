//
//  ReportView.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class ReportView: UIView {
    
    private let scrollView = UIScrollView()
    private let reportHeader = UILabel(labelText: MLabels.reportHeader.rawValue,
                                       textFont: .avenirBold(size: 16),
                                       linesCount: 0)
    private let reportSubHeader = UILabel(labelText: "",
                                          textFont: .avenirRegular(size: 16),
                                          textColor: .myGrayColor(),
                                          linesCount: 0)
    private let reportModeratorInfo = UILabel(labelText: MLabels.reportModeratorInfo.rawValue,
                                          textFont: .avenirRegular(size: 16),
                                          textColor: .myGrayColor(),
                                          linesCount: 0)
    private let selectReportButton = OneLineButtonWithHeader(header: "Тип жалобы", info: MTypeReports.other.rawValue)
    private let textReport = UITextView(text: "", isEditable: true, tag: 1)
    private let sendReportButton = RoundButton(newBackgroundColor: .myLabelColor(), title: "Отправить", titleColor: .myWhiteColor())
    
    weak var delegate: ReportViewDelegate?{
        didSet {
            configure()
        }
    }
    
    init(){
        super.init(frame: .zero)
        setup()
        configure()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.updateContentView(bottomOffset: 200)
    }
    
    func getData() -> (reportType: String, text: String) {
        let reportType = selectReportButton.infoLabel.text ?? ""
        let reportText = textReport.text ?? ""
        return (reportType, reportText)
    }
    
    func configure() {
        guard let delegate = delegate else { return }
        reportSubHeader.text = delegate.reportToFriend() ? MLabels.reportSubHeaderFriend.rawValue : MLabels.reportSubHeader.rawValue
       
    }
    
}

extension ReportView {
    private func setup() {
        backgroundColor = .myWhiteColor()
        selectReportButton.addTarget(self, action: #selector(selectReportTapped), for: .touchUpInside)
        sendReportButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        scrollView.addSingleTapRecognizer(target: self, selector: #selector(scrollViewTapped))
        textReport.addDoneButton()
       
    }
    
    @objc private func selectReportTapped() {
        let vc = SelectionViewController(elements: MTypeReports.modelStringAllCases,
                                         description: MTypeReports.description,
                                         selectedValue: selectReportButton.infoLabel.text ?? "",
                                         complition: {[weak self] selected in
                                            self?.selectReportButton.infoLabel.text = selected
                                         })
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        
        guard let controller = delegate as? UIViewController else { return }
        controller.present(vc, animated: true, completion: nil)
    }
    
    @objc private func sendButtonTapped() {
        delegate?.sendReportTapped()
    }
    
    @objc private func scrollViewTapped() {
        textReport.resignFirstResponder()
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        reportHeader.translatesAutoresizingMaskIntoConstraints = false
        reportSubHeader.translatesAutoresizingMaskIntoConstraints = false
        selectReportButton.translatesAutoresizingMaskIntoConstraints = false
        textReport.translatesAutoresizingMaskIntoConstraints = false
        sendReportButton.translatesAutoresizingMaskIntoConstraints = false
        reportModeratorInfo.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        scrollView.addSubview(reportHeader)
        scrollView.addSubview(reportSubHeader)
        scrollView.addSubview(selectReportButton)
        scrollView.addSubview(textReport)
        scrollView.addSubview(sendReportButton)
        scrollView.addSubview(reportModeratorInfo)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            reportHeader.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            reportHeader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            reportHeader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            reportSubHeader.topAnchor.constraint(equalTo: reportHeader.bottomAnchor, constant: 20),
            reportSubHeader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            reportSubHeader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            selectReportButton.topAnchor.constraint(equalTo: reportSubHeader.bottomAnchor, constant: 35),
            selectReportButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            selectReportButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            selectReportButton.heightAnchor.constraint(equalToConstant: 70),
            
            textReport.topAnchor.constraint(equalTo: selectReportButton.bottomAnchor, constant: 35),
            textReport.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textReport.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            sendReportButton.topAnchor.constraint(equalTo: textReport.bottomAnchor, constant: 35),
            sendReportButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            sendReportButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            sendReportButton.heightAnchor.constraint(equalTo: sendReportButton.widthAnchor, multiplier: 1.0/7.28),
            
            reportModeratorInfo.topAnchor.constraint(equalTo: sendReportButton.bottomAnchor, constant: 35),
            reportModeratorInfo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            reportModeratorInfo.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }
}
