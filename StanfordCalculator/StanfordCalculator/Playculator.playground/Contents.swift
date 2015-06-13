//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

func test2() {
    let css = NSThread.callStackSymbols()
    css.count
    css[0]
    css[1]
    css[2]
    css[3]
    css[4]
    css[5]
    css[6]
    css[7]
    css[8]
    css[9]
    css[10]
    css[11]
    css[12]
}
func test1() {
    test2()
}
test1()

var css = NSThread.callStackSymbols()

var brain = CalculatorBrain()

brain.description

brain.pushInput(3)
brain.description

brain.pushInput(4)
brain.description 

brain.pushInput(5)
brain.description

brain.pushInput(6)
brain.description

brain.pushInput(7)
brain.description

brain.pushInput("+")
brain.description 

brain.pushInput("+")
brain.description

brain.pushInput("+")
brain.description

brain.pushInput("+")
brain.description

var brain2 = CalculatorBrain()
brain2.description

brain2.pushInput(16)
brain2.description

brain2.pushInput(32)
brain2.description

brain2.pushInput("+")
brain2.description

brain2.pushInput("√")
brain2.description

