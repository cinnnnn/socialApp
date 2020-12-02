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
    
    func getStringAge() -> String {
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: self, to: Date())
        return String(age.year!)
    }
    
    func getAge() -> Int {
        let calendar = Calendar.current
        let age = calendar.dateComponents([.year], from: self, to: Date())
        return age.year!
    }
    
    func getPeriod() -> String {
        let calendar = Calendar.current
        let timePeriod = calendar.dateComponents([.second,.minute,.hour,.day,.month,.year], from: self, to: Date())
        if let year = timePeriod.year, year > 0 {
            switch year {
            case let currentYear where (year % 10 == 1) && (year != 11):
                return String("\(currentYear) год назад")
            case let currentYear where (year % 10 >= 2) && (year % 10 <= 4) && (( year < 12) || (year > 14)):
                return String("\(currentYear) года назад")
            default:
                return String("\(year) лет назад")
            }
        } else if let month = timePeriod.month, month > 0 {
            switch month {
            case let currentMonth where (month % 10 == 1) && (month != 11):
                return String("\(currentMonth) месяц назад")
            case let currentMonth where (month % 10 >= 2) && (month % 10 <= 4) && (( month < 12) || (month > 14)):
                return String("\(currentMonth) месяца назад")
            default:
                return String("\(month) месяцев назад")
            }
        } else if let day = timePeriod.day, day > 0 {
            switch day {
            case let currentDay where (day % 10 == 1) && (day != 11):
                return String("\(currentDay) день назад")
            case let currentDay where (day % 10 >= 2) && (day % 10 <= 4) && (( day < 12) || (day > 14)):
                return String("\(currentDay) дня назад")
            default:
                return String("\(day) дней назад")
            }
        } else if let hour = timePeriod.hour, hour > 0 {
            switch hour {
            case let currentHour where (hour % 10 == 1) && (hour != 11):
                return String("\(currentHour) час назад")
            case let currentHour where (hour % 10 >= 2) && (hour % 10 <= 4) && (( hour < 12) || (hour > 14)):
                return String("\(currentHour) часа назад")
            default:
                return String("\(hour) часов назад")
            }
        } else if let minute = timePeriod.minute, minute > 0 {
            switch minute {
            case let currentMinute where (minute % 10 == 1) && (minute != 11):
                return String("\(currentMinute) минута назад")
            case let currentMinute where (minute % 10 >= 2) && (minute % 10 <= 4) && (( minute < 12) || (minute > 14)):
                return String("\(currentMinute) минуты назад")
            default:
                return String("\(minute) минут назад")
            }
        } else if let seconds = timePeriod.second, seconds > 0 {
            switch seconds {
            case let currentSeconds where (seconds % 10 == 1) && (seconds != 11):
                return String("\(currentSeconds) секунда назад")
            case let currentSeconds where (seconds % 10 >= 2) && (seconds % 10 <= 4) && (( seconds < 12) || (seconds > 14)):
                return String("\(currentSeconds) секунды назад")
            default:
                return String("\(seconds) секунд назад")
            }
        } else {
            return "Только что"
        }
    }
    
    func checkPeriodIsPassed(periodMinuteCount: Int) -> Bool {
        let calendar = Calendar.current
        let timePeriod = calendar.dateComponents([.minute], from: self, to: Date())
        if let minute = timePeriod.minute, minute >= periodMinuteCount {
            return true
        } else {
            return false
        }
    }
    
    func checkIsActiveUser() -> Bool {
        let calendar = Calendar.current
        let timePeriod = calendar.dateComponents([.day], from: self, to: Date())
        if let day = timePeriod.day, day <= 7 {
            return true
        } else {
            return false
        }
    }
    
    func checkIsToday() -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(self)
    }
    
    func getDateYearAgo(years: Int) -> Date? {
        Calendar.current.date(byAdding: .year, value: years, to: self)
    }
    
    func getTimerToDate(timerMinuteCount: Int) -> String {
        let calendar = Calendar.current
        guard let timerDate = calendar.date(byAdding: .minute, value: timerMinuteCount, to: self) else { return ""}
        let dateComponentToTimerDate = calendar.dateComponents([.hour,.minute], from: Date(), to: timerDate)
        let hour = dateComponentToTimerDate.hour ?? 0
        let minute = dateComponentToTimerDate.minute ?? 0
        
        return String(format: "%02d:%02d", hour, minute)
    }
    
    func getPeriodToDate(periodMinuteCount: Int) -> String {
        let calendar = Calendar.current
        guard let deleteDate = calendar.date(byAdding: .minute, value: periodMinuteCount, to: self) else { return ""}
        let timeToDeleteDate = calendar.dateComponents([.day,.hour,.minute], from: Date(), to: deleteDate)
       
        if let day = timeToDeleteDate.day, day > 0 {
            switch day {
            case let currentDay where (day % 10 == 1) && (day != 11):
                return String("\(currentDay) день")
            case let currentDay where (day % 10 >= 2) && (day % 10 <= 4) && (( day < 12) || (day > 14)):
                return String("\(currentDay) дня")
            default:
                return String("\(day) дней")
            }
        } else if let hour = timeToDeleteDate.hour, hour > 0 {
            switch hour {
            case let currentHour where (hour % 10 == 1) && (hour != 11):
                return String("\(currentHour) час")
            case let currentHour where (hour % 10 >= 2) && (hour % 10 <= 4) && (( hour < 12) || (hour > 14)):
                return String("\(currentHour) часа")
            default:
                return String("\(hour) часов")
            }
        } else if let minute = timeToDeleteDate.minute, minute > 0 {
            switch minute {
            case let currentMinute where (minute % 10 == 1) && (minute != 11):
                return String("\(currentMinute) минута")
            case let currentMinute where (minute % 10 >= 2) && (minute % 10 <= 4) && (( minute < 12) || (minute > 14)):
                return String("\(currentMinute) минуты")
            default:
                return String("\(minute) минут")
            }
        } else {
            return "0 минут"
        }
    }
}
