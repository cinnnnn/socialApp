//
//  BundleDecode.swift
//  socialApp
//
//  Created by Денис Щиголев on 22.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

extension Bundle {
    
    func decode<T: Decodable>(type: T.Type, from file: String) -> T {
        
        guard let url = url(forResource: file, withExtension: nil) else { fatalError("Failed to locate \(file) in bundle")}
        
        guard let data = try? Data(contentsOf: url) else { fatalError("Failed to load \(file)")}
        
        let decoder = JSONDecoder()
        
        guard let loaded = try? decoder.decode(T.self, from: data) else { fatalError("Can't decode \(file)") }
        
        return loaded
    }
}
