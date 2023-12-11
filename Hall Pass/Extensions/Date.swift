//
//  Date.swift
//  Break Tracker
//
//  Created by Ali Murad on 11/12/2023.
//

import Foundation


extension Date {
    func toDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    func toTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeStyle = .medium
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
            let interval = lhs.timeIntervalSince(rhs)
            return interval / 60 // Convert seconds to minutes
        }
    
    func minuteDifference(to date: Date) -> String {
            let timeInterval = self - date
            
            // Round the time difference to the nearest minute
            let roundedMinutes = Int(timeInterval.rounded())
            
            // Construct the formatted string
            let positiveMinutes = abs(roundedMinutes)
            let minutes = positiveMinutes % 60
            let hours = positiveMinutes / 60
            
            let hourString = hours > 0 ? "\(hours)h " : ""
            let minuteString = "\(minutes)m"
            
            let formattedString = hourString + minuteString
            return formattedString
        }
}
