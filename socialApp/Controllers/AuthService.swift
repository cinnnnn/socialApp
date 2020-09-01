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
        
        auth.createUser(withEmail: email!, password: password!) { result, error in
            
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
        
        auth.signIn(withEmail: email!, password: password!) { result, error in
            
            guard let result = result else {
                complition(.failure(error!))
                return
            }
            
            complition(.success(result.user))
        }
    }
}
