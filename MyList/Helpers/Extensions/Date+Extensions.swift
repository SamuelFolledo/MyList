//
//  Date+Extensions.swift
//  MyList
//
//  Created by Samuel Folledo on 7/1/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

extension Date {
    struct Formatter {
        static let utcFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss'Z'"
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(identifier: "UTC") //load the user's current TimeZone identifier here
            return dateFormatter
        }()
        static let dueDateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") //get time zone
            dateFormatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            return dateFormatter
        }()
        
        static let dueTimeFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") //get time zone
            dateFormatter.dateFormat = "h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            return dateFormatter
        }()
    }
    
    var dateToUTC: String {
        return Formatter.utcFormatter.string(from: self)
    }
    
    var toDueDate: String {
        return Formatter.dueDateFormatter.string(from: self)
    }
    
    var toDueTime: String {
        return Formatter.dueTimeFormatter.string(from: self)
    }
}

extension String {
    struct Formatter {
        static let utcFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssz"
            return dateFormatter
        }()
    }
    
    var dateFromUTC: Date? {
        return Formatter.utcFormatter.date(from: self)
    }
}
