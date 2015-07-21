//: Playground - noun: a place where people can play
import UIKit
import XCPlayground
func testCallStack() {
    let css = NSThread.callStackSymbols()
    css.count
    css[0]
}
testCallStack()

var brain = CalculatorBrain()
//var calcVC = CalculatorViewController()


//var ctrl = ()
// ctrl.viewDidLoad() //Not needed
//ctrl.view
