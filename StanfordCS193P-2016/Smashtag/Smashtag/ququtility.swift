//
//  ququtility.swift
//  Quote-Unquote "Utility", aka a grab bag of functions and bullshit
//  Don't write modules like this, do something else, this is just for fucking around
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-09-13.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

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

func logFailedGuard(
    function: String = __FUNCTION__,
    file: String = __FILE__,
    line: Int = __LINE__)
{
    macrolog("Guard failure", function: function, file: file, line: line)
}

func unwrapNavigationController<ControllerType>(
    navigationController: UINavigationController,
    ofType: ControllerType)
    -> ControllerType?
{
    if let destination = navigationController.visibleViewController as? ControllerType {
        return destination
    }
    else {
        return nil
    }
}

func unwrapNavigationControllerForSegue<ControllerType>(
    segue: UIStoryboardSegue,
    ofType: ControllerType)
    -> ControllerType?
{
    var destination: ControllerType?
    if let navVC = segue.destinationViewController as? UINavigationController {
        if let targetVC = navVC.visibleViewController as? ControllerType {
            destination = targetVC
        }
    }
    else if let targetVC = segue.destinationViewController as? ControllerType {
        destination = targetVC
    }
    return destination
}