//
//  AuthService.swift
//  socialApp
//
//  Created by Денис Щиголев on 01.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class AuthService {
    
    static let shared = AuthService()
    private let auth = Auth.auth()
    
    private init() {}
    
    
    //MARK: - register
    func register(email: String?,
                  password: String?,
                  confirmPassword: String?,
                  complition: @escaping (Result<User, Error>) -> Void ) {
        
        let isFilledCheck = Validators.shared.isFilledRegister(email: email,
                                                              password: password,
                                                              confirmPassword: confirmPassword)
        
        guard isFilledCheck.isFilled else { complition(.failure(AuthError.notFilled))
                                            return }
        

        guard Validators.shared.isConfirmPassword(password1: isFilledCheck.password, password2: isFilledCheck.confirmPassword) else {
            complition(.failure(AuthError.passwordNotMatch))
            return
        }
        
        guard Validators.shared.isEmail(email: isFilledCheck.email) else {
            complition(.failure(AuthError.invalidEmail))
            return
        }
        
        auth.createUser(withEmail: isFilledCheck.email, password: isFilledCheck.password) { result, error in
            
            guard let result = result else {
                complition(.failure(error!))
                return
            }
            complition(.success(result.user))
        }
    }

        //MARK: - signIn
    func signIn(email: String?,
                password: String?,
                complition: @escaping (Result<User,Error>) -> Void) {
        
        let isFilledCheck = Validators.shared.isFilledSignIn(email: email, password: password)
        
        guard isFilledCheck.isFilled else { complition(.failure(AuthError.notFilled))
                                            return
                                          }
        
        auth.signIn(withEmail: isFilledCheck.email, password: isFilledCheck.password) { result, error in
            
            guard let result = result else {
                complition(.failure(error!))
                return
            }
            
            complition(.success(result.user))
        }
    }
}
