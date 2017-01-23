//
//  extensions.swift
//  ControleDeGastos
//
//  Created by Felipe Viberti on 4/4/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation
import SystemConfiguration

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
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

open class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    
}
