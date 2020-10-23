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
    
    
    func isFilledUserName(userName: String? ) -> (isFilled: Bool,
                                                  userName: String) {
        guard let userName = userName,
              userName != ""
              else { return (false, "") }
        
        return (true, userName)
    }
    
    func isSetProfileImage(image: UIImage) -> Bool {
        return true
    }
    
    
    func isEmail(email: String) -> Bool {
        
        let mailRegEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        return checkRegEx(text: email, regEx: mailRegEX)
    }
    
     func isConfirmPassword(password1: String, password2: String) -> Bool {
 
        return password1 == password2
    }
    
    //ListnerAddValidator
    
    func listnerAddPeopleValidator(currentPeople: MPeople,
                                   newPeople: MPeople,
                                   peopleDelegate: PeopleListenerDelegate,
                                   likeDislikeDelegate: LikeDislikeDelegate,
                                   acceptChatsDelegate: AcceptChatsDelegate,
                                   isUpdate: Bool) -> Bool {
        if !isUpdate {
        //if not present in people array
        guard !peopleDelegate.peopleNearby.contains(newPeople) else { return false }
        }
        //if not current user
        guard newPeople.senderId != currentPeople.senderId else { return false }
        //if not inActive user
        guard newPeople.isActive == true else { return false}
        //if not blocked user
        guard newPeople.isBlocked == false else { return false}
        //if not already like
        guard !likeDislikeDelegate.likePeople.contains(where: { chat -> Bool in
            chat.friendId == newPeople.senderId
        }) else { return false }
        //if not already dislike
        guard !likeDislikeDelegate.dislikePeople.contains(where: { chat -> Bool in
            chat.friendId == newPeople.senderId
        }) else { return false }
        //if not in new chat
        guard !acceptChatsDelegate.acceptChats.contains(where: { chat -> Bool in
            chat.friendId == newPeople.senderId
        }) else { return false }
        //check distance to people
        let distance = LocationService.shared.getDistance(currentPeople: currentPeople, newPeople: newPeople)
        let range = currentPeople.searchSettings[MSearchSettings.distance.rawValue] ?? MSearchSettings.distance.defaultValue
        guard distance <= range else { return false }
        //if newPeople is looking for
        guard newPeople.gender == MLookingFor.compareGender(gender: currentPeople.lookingFor) else { return false }
        //if age range correct
        let age = newPeople.dateOfBirth.getAge()
        let minRange = currentPeople.searchSettings[MSearchSettings.minRange.rawValue] ?? MSearchSettings.minRange.defaultValue
        let maxRange = currentPeople.searchSettings[MSearchSettings.maxRange.rawValue] ?? MSearchSettings.maxRange.defaultValue
        guard age >= minRange && age <= maxRange else { return false }
        return true
    }
    
    private func checkRegEx(text: String, regEx: String) -> Bool {
        let textCheck  = NSPredicate(format:"SELF MATCHES %@", regEx)
        return textCheck.evaluate(with: text)
    }
}
