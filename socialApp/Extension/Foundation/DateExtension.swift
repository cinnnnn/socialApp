//
//  DateExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

extension Date {
    
    func getFormattedDate(format: String, withTime: Bool? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        if let withTime = withTime {
            if !withTime {
                dateFormatter.timeStyle = .none
            }
        }
        
        return dateFormatter.string(from: self)
    }
    
    func getShortFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: self)
    }
    
    func getAge() -> String {
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: self, to: Date())
        return String(age.year!)
    }
    
    func getPeriod() -> String {
        let calendar = Calendar.current
        let timePeriod = calendar.dateComponents([.minute,.hour,.day,.month,.year], from: self, to: Date())
        if let year = timePeriod.year, year > 0 {
            switch year {
            case 1:
                return String("\(year) год назад")
            case let currentYear where (year % 10 >= 2) && (year % 10 <= 4):
                return String("\(currentYear) года назад")
            default:
                return String("\(year) лет назад")
            }
        } else if let month = timePeriod.month, month > 0 {
            switch month {
            case 1:
                return String("\(month) месяц назад")
            case let currentMonth where (month % 10 >= 2) && (month % 10 <= 4):
                return String("\(currentMonth) месяца назад")
            default:
                return String("\(month) месяцев назад")
            }
        } else if let day = timePeriod.day, day > 0 {
            switch day {
            case 1:
                return String("\(day) день назад")
            case let currentDay where (day % 10 >= 2) && (day % 10 <= 4):
                return String("\(currentDay) дня назад")
            default:
                return String("\(day) дней назад")
            }
        } else if let hour = timePeriod.hour, hour > 0 {
            switch hour {
            case 1:
                return String("\(hour) час назад")
            case let currentHour where (hour % 10 >= 2) && (hour % 10 <= 4):
                return String("\(currentHour) часа назад")
            default:
                return String("\(hour) часов назад")
            }
        } else if let minute = timePeriod.minute, minute > 0 {
            switch minute {
            case 1:
                return String("\(minute) минута назад")
            case let currentMinute where (minute % 10 >= 2) && (minute % 10 <= 4):
                return String("\(currentMinute) минуты назад")
            default:
                return String("\(minute) минут назад")
            }
        } else {
            return "Только что"
        }
    }
}
