//
//  ReportViewDelegate.swift
//  socialApp
//
//  Created by Денис Щиголев on 03.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

protocol ReportViewDelegate: class {
    func reportToFriend() -> Bool
    func sendReportTapped()
}
