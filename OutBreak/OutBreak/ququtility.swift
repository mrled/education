//
//  DefaultsWrapper.swift
//  OutBreak
//
//  Created by Micah R Ledbetter on 2015-12-10.
//  Copyright © 2015 Micah R Ledbetter. All rights reserved.
//

import Foundation

class Defaults {
    static func objectForKey(key: String) -> AnyObject? {
        let object = NSUserDefaults.standardUserDefaults().objectForKey(key)
//        print("objectForKey(\(key)) -> \(object)")
        return object
    }
    static func objectForKey<T> (key: String, withDefault defaultValue: T) -> T {
        if let object = NSUserDefaults.standardUserDefaults().objectForKey(key) as? T {
//            print("objectForKey(\(key), withDefault: \(defaultValue)) -> \(object) -- from NSUserDefaults")
            return object
        }
        else {
//            print("objectForKey(\(key), withDefault: \(defaultValue)) -> \(defaultValue) -- use default value")
            return defaultValue
        }
    }
    static func setObject (object: AnyObject?, forKey key: String) {
//        print("setObject(\(object), forKey: \(key)")
        NSUserDefaults.standardUserDefaults().setObject(object, forKey: key)
    }
}

// NOTE: the __MACRO__ -like thing are expanded in the CALLING context b/c they're in the parameter block!
// (Which is exactly what we want)
// See: https://developer.apple.com/swift/blog/?id=15
// Also helpful: http://practicalswift.com/2014/06/10/list-of-implicitly-defined-variables-in-swift/
func macrolog(
    message: String,
    function: String = __FUNCTION__,
    file: String = __FILE__,
    line: Int = __LINE__)
{
    let uFile = NSURL(fileURLWithPath: file)
    print("\(message) - in \(function) @ \(uFile.lastPathComponent):\(line)")
}
