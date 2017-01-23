//
//  SimplePList.swift
//  PListNanoChallenge
//
//  Created by Andre Machado Parente on 4/19/16.
//  Copyright © 2016 Andre Machado Parente. All rights reserved.
//

import Foundation

public let plist = SimplePList(plistName: "User")

open class SimplePList {
    
    var plistName:String
    fileprivate var path:String = ""
    
    init (plistName:String) {
        
        self.plistName = plistName
        self.path = getPath(plistName)
    }
    
    func getPath(_ plistName:String)->String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String + "/" + plistName + ".plist"
    }
    
    func deleteData(_ dataToSave:[String:AnyObject]) {
       let content = dataToSave as NSDictionary
        content.write(toFile: path, atomically: false)
    }
    
    
    func saveData(_ dataToSave:[String:AnyObject])->Bool {
        let content = dataToSave as NSDictionary
        let result = content.write(toFile: path, atomically: false)
        return result
    }
    
    
    func getData()->[String:AnyObject]? {
        let content = NSDictionary(contentsOfFile: path)
        return content as? [String:AnyObject]
    }
}
