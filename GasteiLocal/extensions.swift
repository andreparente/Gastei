//
//  extensions.swift
//  ControleDeGastos
//
//  Created by Felipe Viberti on 4/4/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation


extension Double {
    /// Rounds the double to decimal places value
      func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String {
    func toDouble() -> Double? {
        if (self == "") {
            return 0.0
        }
        return NumberFormatter().number(from: self)?.doubleValue
    }
}

extension Date {
    func changeDaysBy(_ days : Int) -> Date {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.day = days
        return (Calendar.current as NSCalendar).date(byAdding: dateComponents, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
    }
    
    func createFromDate(_ dia: Int, mes: Int, ano: Int) -> Date {
        var components = (Calendar.current as NSCalendar).components([.day, .month, .year], from: Date())
        components.day = dia
        components.month = mes
        components.year = ano
        let timeInterval = (Calendar(identifier: Calendar.Identifier.gregorian).date(from: components)!.timeIntervalSince1970)
        return Date(timeIntervalSince1970: timeInterval)
    }
}

extension String {
    
    func hexStringtoAscii() -> String {
        
        let pattern = "(0x)?([0-9a-f]{2})"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let nsString = self as NSString
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        let characters = matches.map {
            Character(UnicodeScalar(UInt32(nsString.substring(with: $0.rangeAt(2)), radix: 16)!)!)
        }
        return String(characters)
    }
}

