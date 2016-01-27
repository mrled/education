//
//  DiagnosisWithHistoryVC.swift
//  Psychologist
//
//  Created by Micah R Ledbetter on 2015-06-29.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class DiagnosisWithHistoryVC: DiagnosisViewController, UIPopoverPresentationControllerDelegate {
    private let defaults = NSUserDefaults.standardUserDefaults()
    var diagHistory: [Int] {
        get { return defaults.objectForKey(Constants.DefaultsKey) as? [Int] ?? [] }
        set { defaults.setObject(newValue, forKey: Constants.DefaultsKey) }
    }
    override var happiness: Int {
        didSet {
            diagHistory += [happiness]
        }
    }
    private struct Constants {
        static let SegueIdentifier = "Recall Permanent File"
        static let DefaultsKey = "DiagnosticHistory"
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Constants.SegueIdentifier:
                if let histvc = segue.destinationViewController as? DiagHistoryVC {
                    if let ppc = histvc.popoverPresentationController {
                        ppc.delegate = self
                    }
                    histvc.text = "\(diagHistory)"
                }
            default: break
            }
        }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
}