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


brain.pushInput(2)
brain.pushInput(3)
brain.pushInput("×")
brain.pushInput("M")
brain.evaluate()
brain.assignVariable("M", value: 4)