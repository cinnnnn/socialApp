//
//  MReports.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import FirebaseFirestore

struct MReports: Codable, Hashable{
    var reportUserID: String
    var typeOfReports: String
    var text: String
    
    init(reportUserID: String, typeOfReports: MTypeReports, text: String){
        self.reportUserID = reportUserID
        self.typeOfReports = typeOfReports.rawValue
        self.text = text
    }
    
    init(json: [String: Any]) {
        if let reportUserID = json["reportUserID"] as? String {
            self.reportUserID = reportUserID
        } else {
            self.reportUserID = ""
        }
        if let typeOfReports = json["typeOfReports"] as? String {
            self.typeOfReports = typeOfReports
        } else {
            self.typeOfReports = ""
        }
        if let text = json["text"] as? String {
            self.text = text
        } else {
            self.text = ""
        }
    }
    
    init?(documentSnap: QueryDocumentSnapshot ) {
        let document = documentSnap.data()
        guard let reportUserID = document["reportUserID"] as? String else { return nil }
        guard let typeOfReports = document["typeOfReports"] as? String else { return nil }
        guard let text = document["text"] as? String else { return nil }
        
        self.reportUserID = reportUserID
        self.typeOfReports = typeOfReports
        self.text = text
    }
    
    enum CodingKeys: String, CodingKey  {
        case reportUserID
        case typeOfReports
        case text
    }
}
