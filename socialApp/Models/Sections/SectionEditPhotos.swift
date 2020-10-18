//
//  SectionEditPhotos.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum SectionEditPhotos: Int, CaseIterable {
      case photos
      
      func description() -> String {
          switch self {
          case .photos:
              return "Фото"
          }
      }
  }
