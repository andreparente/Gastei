//
//  SimplePList.swift
//  PListNanoChallenge
//
//  Created by Andre Machado Parente on 4/19/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation

public let plist = SimplePList(plistName: "User")

public class SimplePList {
    
    var plistName:String
    private var path:String = ""
    
    init (plistName:String) {
        
        self.plistName = plistName
        self.path = getPath(plistName)
    }
    
    func getPath(plistName:String)->String {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String + "/" + plistName + ".plist"
    }
    
    func deleteData(dataToSave:[String:AnyObject]) {
       let content = dataToSave as NSDictionary
        content.writeToFile(path, atomically: false)
    }
    
    
    func saveData(dataToSave:[String:AnyObject])->Bool {
        let content = dataToSave as NSDictionary
        let result = content.writeToFile(path, atomically: false)
        return result
    }
    
    
    func getData()->[String:AnyObject]? {
        let content = NSDictionary(contentsOfFile: path)
        return content as? [String:AnyObject]
    }
}