//
//  ququtility.swift
//  Quote-Unquote "Utility", aka a grab bag of functions and bullshit
//  Don't write modules like this, do something else, this is just for fucking around
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-09-13.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import Foundation

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

