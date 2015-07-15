//
//  CalculatorViewController.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-02-22.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

@IBDesignable
class CalculatorViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var blankButton: PlaceholderButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private struct Constants {
        static let TrigSegueIdentifier = "Show Trig Functions"
    }
    
    var midTyping = false;
    
    var brain = CalculatorBrain()
    
    var displayValue: Double? {
        get {
            if let dText = display.text {
                if let nsnum = NSNumberFormatter().numberFromString(dText) {
                    return nsnum.doubleValue
                }
            }
            return nil
        }
        set {
            history.text = brain.description
            midTyping = false
            if let nv = newValue {
                display.text = "\(nv)"
            }
            else {
                display.text = ""
            }
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if midTyping {
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            midTyping = true
        }
    }
    @IBAction func appendDecimal() {
        let cdecimal: Character = "."
        if let dText = display.text {
            // if there's already a decimal in the display, do nothing
            if find(dText, cdecimal) == nil {
                display.text = dText + "."
            }
        }
        else {
            display.text = "0."
        }
    }

    @IBAction func operate(sender: UIButton) {
        if midTyping { enter() }
        displayValue = nil
        var success = false
        history.text = brain.description
        if let operation = sender.currentTitle {
            if let result = brain.pushInput(operation) {
                displayValue = result
            }
        }
    }
    
    @IBAction func enter() {
        midTyping = false
        displayValue = brain.pushInput(displayValue)
        println("==== ENTER ====")
    }
    
    @IBAction func backspace() {
        let lastDigit = count(display.text!) - 1
        if lastDigit >= 0 {
            let idx = advance(display.text!.startIndex, lastDigit)
            display.text = display.text!.substringToIndex(idx)
        }
        // TODO: think about this, not sure if covers pathological cases
    }
    
    @IBAction func clear() {
        displayValue = nil
    }
    
    @IBAction func clearStack() {
        midTyping = false
        brain.clearStack()
        history.text = brain.description
        clear()
    }
    
    @IBAction func insertConstant(sender: UIButton) {
        displayValue = brain.pushInput(sender.currentTitle)
    }
    
    @IBAction func saveMem(sender: UIButton) {
        midTyping = false
        // chop off the leading → character & assign the value
        var memSymbol = sender.currentTitle!
        memSymbol.removeAtIndex(memSymbol.startIndex)
        brain.assignVariable(memSymbol, value: displayValue!)
    }
    @IBAction func recallMem(sender: UIButton) {
        if midTyping { enter() }
        brain.pushVariable(sender.currentTitle!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.TrigSegueIdentifier:
                if let trigvc = segue.destinationViewController as? TrigViewController {
                    trigvc.calculatorButtonHeight = fourButton.frame.height
                    trigvc.calculatorButtonWidth = fourButton.frame.width
                    trigvc.calculatorVC = self
                    if let ppc = trigvc.popoverPresentationController {
                        ppc.delegate = self
                    }
                }
            default: break
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    override func prepareForInterfaceBuilder() {
        display.text = "HI"
    }
}

