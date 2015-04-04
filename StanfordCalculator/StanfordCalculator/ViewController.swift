//
//  ViewController.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-02-22.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    var midTyping = false;
    
    var brain = CalculatorBrain()
    
    // TODO: This must be an optional for homework purposes
    //       That might actually make error handling easier
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            midTyping = false
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        clearError()
        if midTyping {
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            midTyping = true
        }
    }
    @IBAction func appendDecimal() {
        clearError()
        
        let cdecimal: Character = "."
        if let dText = display.text {
            if let idx = find(dText, cdecimal) {
                // If there's already a decimal in the display, error
                displayError()
            }
            else {
                display.text = dText + "."
            }
        }
        else {
            display.text = "0."
        }
    }

    @IBAction func operate(sender: UIButton) {
        if midTyping { enter() }
        clearError()
        
        var success = false
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
                success = true
            }
        }
        if !success {
            displayError()
        }
    }
    
    @IBAction func enter() {
        clearError()
        midTyping = false
        history.text = brain.retrieveInputs()
        if let result = brain.pushInput(displayValue) {
            displayValue = result
        }
        else {
            displayError()
        }
    }
    
    @IBAction func backspace() {
        clearError()
        let lastDigit = countElements(display.text!) - 1
        if lastDigit >= 0 {
            let idx = advance(display.text!.startIndex, lastDigit)
            display.text = display.text!.substringToIndex(idx)
        }
        else {
            displayError()
        }
    }
    
    @IBAction func clear() {
        clearError()
        displayValue = 0
    }
    
    @IBAction func clearStack() {
        clearError()
        midTyping = false
        brain.clearStack()
        history.text = brain.retrieveInputs()
        clear()
    }
    
    @IBAction func insertConstant(sender: UIButton) {
        clearError()
        if let evaluation = brain.pushInput(sender.currentTitle) {
            displayValue = evaluation
        }
        else {
            displayError()
        }
    }
    
    func performInsertConstant(constant: Double) {
        if midTyping { enter() }
        brain.pushInput(constant)
        displayValue = constant
    }
    
    func displayError() {
        display.hidden = true
        errorLabel.hidden = false
    }
    func clearError() {
        display.hidden = false
        errorLabel.hidden = true
    }
}

