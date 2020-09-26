//
//  UserDefaultsService.swift
//  socialApp
//
//  Created by Денис Щиголев on 25.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

class UserDefaultsService {
    
    static let shared = UserDefaultsService()
    
    private let userDefaults = UserDefaults.standard
    private let peopleKey = "people"
    private init() { }
    
    func saveMpeople(people: MPeople?) {
        guard let people = people else { fatalError("people is nil")}
        guard let data = try? PropertyListEncoder().encode(people) else { fatalError("Cant encode people to data")}
        
        userDefaults.set(data, forKey: peopleKey)
    }
    
    func getMpeople()-> MPeople? {
        guard let data = userDefaults.value(forKey: peopleKey) as? Data else { fatalError("Cant get data from peopleKey")}
        guard let decodeData = try? PropertyListDecoder().decode(MPeople.self, from: data) else { fatalError("Cant decode data")}
        //let people = MPeople(data: unwrapData)
        return decodeData
    }
    
    func deleteMpeople() {
        userDefaults.removeObject(forKey: peopleKey)
    }
}
