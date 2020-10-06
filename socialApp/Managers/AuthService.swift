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
import AuthenticationServices
import CryptoKit

class AuthService {
    
    static let shared = AuthService()
    private let auth = Auth.auth()
    var currentNonce: String?  //hashed nonce string
    
    private init() {}
    
    func isEmailAlreadyRegister(email: String?, complition: @escaping(Result<Bool,Error>) -> Void) {
        guard let email = email else { return }
        
        auth.fetchSignInMethods(forEmail: email) { (methods, error) in
            if let error = error {
                complition(.failure(error))
            } else if methods != nil {
                complition(.success(true))
            } else {
                complition(.success(false))
            }
        }
    }
    
    func verifyEmail(user: User, complition: @escaping(Result<Bool,Error>) -> Void) {
        
        user.sendEmailVerification { error in
            

        }
    }
    
    //MARK: - sendAppleIdRequest
    //send appleIdRequset to signIn
    func AppleIDRequest(delegateController: ASAuthorizationControllerDelegate,
                        presetationController: ASAuthorizationControllerPresentationContextProviding) {
        let request = createAplleIDRequest()
        let authController = ASAuthorizationController(authorizationRequests: [request])
        
        authController.delegate = delegateController
        authController.presentationContextProvider = presetationController
        
        authController.performRequests()
    }
    
    //MARK: - getCredentialApple
    //after complite auth get token and push to FirebaseAuth
    func didCompleteWithAuthorizationApple(authorization: ASAuthorization,
                                           complition: @escaping (Result<OAuthCredential,Error>) -> Void) {
        
        if let authCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else { fatalError("No login request was sent")}
            
            guard let appleIDToken = authCredential.identityToken else {
                complition(.failure(AuthError.appleToken))
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                complition(.failure(AuthError.serializeAppleToken))
                return
            }
            
             let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
                
             complition(.success(credential))
        }
    }
    
    //MARK: - signInApple
    func signInApple(with credential: OAuthCredential, complition: @escaping (Result<User, Error>) -> Void) {
        
        auth.signIn(with: credential) { data, error in
            if let user = data?.user {
                complition(.success(user))
            } else if let error = error {
                complition(.failure(error))
            }
        }
    }
    
    
    //MARK: - register mail
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
        
        
        auth.createUser(withEmail: isFilledCheck.email, password: isFilledCheck.password) { result, error in
            
            guard let result = result else {
                complition(.failure(error!))
                return
            }
            complition(.success(result.user))
        }
    }
    
    //MARK: - signIn mail
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
    
    //MARK: - signOut
    func signOut(complition: @escaping (Result<Bool,Error>)-> Void) {
        do {
            try Auth.auth().signOut()
            
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
            keyWindow?.rootViewController = AuthViewController()
            complition(.success(true))
        } catch {
            complition(.failure(error))
        }
    }
}

//MARK: -  appleIDRequest
extension AuthService {
    
    private func createAplleIDRequest() ->ASAuthorizationAppleIDRequest {
        
        let appleIDAuthProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDAuthProvider.createRequest()
        request.requestedScopes = [.fullName, .email ]
        
        let nonce = CryptoService.shared.randomNonceString()
        request.nonce = CryptoService.shared.sha256(nonce)
        currentNonce = nonce
        
        return request
    }
}
