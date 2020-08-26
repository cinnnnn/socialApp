//
//  SectionsPeople.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum SectionsPeople: Int, CaseIterable {
      case main
      
      func description() -> String {
          switch self {
          case .main:
              return "Люди рядом"
          }
      }
  }
