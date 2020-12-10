//
//  Date+Extension.swift
//  PracticeFireAuth
//
//  Created by TAKEBUMI SUZUKI on 12/6/20.
//  Copyright © 2020 TAKEBUMI SUZUKI. All rights reserved.
//

import Foundation

extension Date{
    
    static func getString(date: Date) -> String{
        
        let df = DateFormatter()
        //df.locale = Locale(identifier: "ja_JP")  //もし日本語表記を試したい場合はこの行をオンに。
        //df.timeZone = TimeZone(identifier: "Asia/Tokyo")
        switch true {
        case Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date):
            df.doesRelativeDateFormatting = true
            df.dateStyle = .short
            df.timeStyle = .short
        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear):
            df.dateFormat = "EEEE h:mm a"
        case Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year):
            df.dateFormat = "E, d MMM, h:mm a"
        default:
            df.dateFormat = "MMM d, yyyy, h:mm a"
        }
        let dateString = df.string(from: date)
        let dateStringVer2 = dateString.replacingOccurrences(of: "Today, ", with: "")
        let dateStringVer3 = dateStringVer2.replacingOccurrences(of: "今日 ", with: "")
        return dateStringVer3
    }
}
