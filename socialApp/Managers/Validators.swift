//
//  Validators.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth

class Validators {
    
    static let shared = Validators()
    
    private init() {}
    
    //MARK: isFilledRegister
    func isFilledRegister(email: String?, password: String?, confirmPassword: String? ) -> (isFilled: Bool,
                                                                                            email: String,
                                                                                            password: String,
                                                                                            confirmPassword: String) {
        guard let email = email,
              let password = password,
              let confirmPassword = confirmPassword,
              email != "",
              password != "",
              confirmPassword != ""
        else { return (false, "", "", "") }
        
        return (true, email, password, confirmPassword)
    }
    
    //MARK: isFilledSignIn
    func isFilledSignIn(email: String?, password: String?) -> (isFilled: Bool,
                                                               email: String,
                                                               password: String) {
        guard let email = email,
              let password = password,
              email != "",
              password != ""
        else { return (false, "", "") }
        
        return (true, email, password)
    }
    
    //MARK: isFilledUserName
    func isFilledUserName(userName: String? ) -> (isFilled: Bool,
                                                  userName: String) {
        guard let userName = userName,
              userName != ""
        else { return (false, "") }
        
        return (true, userName)
    }
    
    //MARK: isSetProfileImage
    func isSetProfileImage(image: UIImage) -> Bool {
        return true
    }
    
    
    //MARK: isEmail
    func isEmail(email: String) -> Bool {
        
        let mailRegEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        return checkRegEx(text: email, regEx: mailRegEX)
    }
    
    //MARK: isConfirmPassword
    func isConfirmPassword(password1: String, password2: String) -> Bool {
        
        return password1 == password2
    }
    
    //MARK: listnerAddRequestValidator
    func listnerAddRequestValidator(userID: String,
                                    newRequestChat: MChat,
                                    requestDelegate: RequestChatListenerDelegate,
                                    reportsDelegate: ReportsListnerDelegate) -> Bool {
        
       //if already have in request, don't add him to collection
        guard !requestDelegate.requestChats.contains(where: { requestChat -> Bool in
            requestChat.friendId == newRequestChat.friendId
        }) else { return false }
        //if this user have report, don't add him to collection
        guard !reportsDelegate.reports.contains(where: { report -> Bool in
            report.reportUserID == newRequestChat.friendId
        }) else { return false }
        return true
    }
    
    func checkTagsIsFilled(tags:[String]) -> Bool {
        tags.count >= 3
    }
    
    //MARK: checkRegEx
    private func checkRegEx(text: String, regEx: String) -> Bool {
        let textCheck  = NSPredicate(format:"SELF MATCHES %@", regEx)
        return textCheck.evaluate(with: text)
    }
}
