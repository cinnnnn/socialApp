//
//  ReportsDataProvider.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

class ReportsDataProvider: ReportsListnerDelegate {
    
    var reports: [MReports] = []
    var userID: String
    
    init(userID: String){
        self.userID =  userID
    }
}

extension ReportsDataProvider {
    //MARK:  get like dislike
    func getReports(complition: @escaping (Result<[MReports], Error>) -> Void) {
        FirestoreService.shared.getReports(userID: userID) {[weak self] result in
            switch result {
            
            case .success(let reports):
                self?.reports = reports
                complition(.success(reports))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
}
