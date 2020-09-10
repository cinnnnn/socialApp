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
    
    //MARK: - signIn Apple
    //after complite auth get token and push to FirebaseAuth
    func didCompleteWithAuthorizationApple(authorization: ASAuthorization,
                                           complition: @escaping (Result<User,Error>) -> Void) {
        
        if let authCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard let nonce = currentNonce else { fatalError("No login request was sent")}
            
            guard let appleIDToken = authCredential.identityToken else {
                print("Unable to return Apple Token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token to string")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            auth.signIn(with: credential) { data, error in
                if let user = data?.user {
                    complition(.success(user))
                } else if let error = error {
                    complition(.failure(error))
                }
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
}


//MARK: -  appleIDRequest
extension AuthService {
    
    private func createAplleIDRequest() ->ASAuthorizationAppleIDRequest {
        
        let appleIDAuthProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDAuthProvider.createRequest()
        request.requestedScopes = [.fullName, .email ]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        
        return request
    }
    
    //MARK: - random nonce string
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
