//
//  Utility.swift
//  Check My Wallet
//
//  Created by Anh Dinh on 10/11/23.
//

import Foundation

class Utility {
    /// Convert TimeInverval to Date Format
    static func convertTimeIntervalToDateFormat(timeInterval: TimeInterval) -> String {
        // convert TimeInterval to Date() class
        let date = Date(timeIntervalSince1970: TimeInterval(timeInterval))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
    }
}
