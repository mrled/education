//
//  TrigViewController.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-07-11.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class TrigViewController: UIViewController {
    @IBOutlet weak var cosButton: UIButton!
    @IBOutlet weak var sinButton: UIButton!
    @IBOutlet weak var tanButton: UIButton!
    @IBAction func callTrigFunction(sender: UIButton) {
        if let calcVC = calculatorVC {
            calcVC.operate(sender)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
    var calculatorVC: CalculatorViewController?
    var calculatorButtonHeight: CGFloat?
    var calculatorButtonWidth: CGFloat?
    override func viewWillAppear(animated: Bool) {
        if calculatorButtonHeight != nil && calculatorButtonWidth != nil {
            let width  = calculatorButtonWidth!
            let height = calculatorButtonHeight!
            for button in [cosButton, sinButton, tanButton] {
                var buttonTitle = ""
                if let tl = button.titleLabel { if let t = tl.text { buttonTitle = t }}
                println("Trying to set dimensions for \(buttonTitle) to be \(width)x\(height)")
                let heightConstraint = NSLayoutConstraint(
                    item: button,
                    attribute: NSLayoutAttribute.Height,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1,
                    constant: height)
                let widthConstraint = NSLayoutConstraint(
                    item: button,
                    attribute: NSLayoutAttribute.Width,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1,
                    constant: width)
                button.addConstraint(heightConstraint)
                button.addConstraint(widthConstraint)
            }

        
        }
    }
    override var preferredContentSize: CGSize {
        //get { return super.preferredContentSize }
        get {
            let preferredSize = CGSize(width: 500, height: 200)
            return preferredSize
        }
        set { super.preferredContentSize = newValue}
    }
}
