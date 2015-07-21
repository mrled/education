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
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var memoryButton: UIButton!
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private struct Constants {
        static let TrigSegueIdentifier = "Show Trig Functions"
        static let CalcBrainMemId = "M"
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
    
    func clear() {
        displayValue = nil
    }
    
    func clearStack() {
        midTyping = false
        brain.clearStack()
        history.text = brain.description
        clear()
    }
    
    @IBAction func insertConstant(sender: UIButton) {
        displayValue = brain.pushInput(sender.currentTitle)
    }
    
    func saveMem() {
        midTyping = false
        brain.assignVariable(Constants.CalcBrainMemId, value: displayValue!)
    }
    func recallMem() {
        if midTyping { enter() }
        brain.pushVariable(Constants.CalcBrainMemId)
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
    
    func setupGestures() {
        // clearButton:
        let clearButtonTap = UITapGestureRecognizer(target: self, action:"clear")
        clearButtonTap.numberOfTapsRequired = 1
        let clearButtonLongPress = UILongPressGestureRecognizer(target: self, action:"clearStack")
        clearButton.addGestureRecognizer(clearButtonTap)
        clearButton.addGestureRecognizer(clearButtonLongPress)
        // memoryButton:
        let memButtonTap = UITapGestureRecognizer(target: self, action:"recallMem")
        memButtonTap.numberOfTapsRequired = 1
        let memButtonLongPress = UILongPressGestureRecognizer(target:self, action:"saveMem")
        memoryButton.addGestureRecognizer(memButtonTap)
        memoryButton.addGestureRecognizer(memButtonLongPress)
    }
    
    override func viewDidLoad() {
        setupGestures()
    }

}


@IBDesignable
extension UIButton {
    var placeholderBackgroundColor: UIColor { return self.currentTitleColor }
    @IBInspectable var isPlaceholder: Bool {
        get {
            #if TARGET_INTERFACE_BUILDER
                return self.backgroundColor == self.placeholderBackgroundColor
            #else
                return false
            #endif
        }
        set {
            #if TARGET_INTERFACE_BUILDER
                if oldValue { // oldValue was true, so make this false, i.e. make this not a placeholder
                    self.backgroundColor = super.backgroundColor
                }
                else { // oldValue was false, so make this true, i.e. make this a placeholder
                    self.backgroundColor = self.placeholderBackgroundColor
                }
            #endif
        }
    }
}
*/