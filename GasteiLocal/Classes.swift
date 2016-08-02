//
//  Classes.swift
//  ControleDeGastos
//
//  Created by Andre Machado Parente on 3/23/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import UIKit
import CoreData

public let screenSize = UIScreen.mainScreen().bounds

public let corVerde = UIColor(red:0, green:0.60, blue:0.89, alpha:1.0)
public let corAzul = UIColor(red:(51.0/255), green:(204.0/255), blue:1, alpha:1.0)
//public let corAmarela = UIColor(red:(204.0/255),green:(204.0/255),blue:0,alpha: 1.0)
public let corVermelha = UIColor(red:1,green:0,blue:0,alpha:1.0)
//public var eamarela = false
public var evermelha = false
public var eazul = true
public let defaults = NSUserDefaults.standardUserDefaults()


func isValidEmail(testStr:String) -> Bool {
    
    let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(testStr)
}