//
//  PsychologistViewController.swift
//  Psychologist
//
//  Created by Micah R Ledbetter on 2015-06-23.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class PsychologistViewController: UIViewController {

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let hvc = segue.destinationViewController as? DiagnosisViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "Diagnose Stygian Horrors":    hvc.happiness = 20
                case "Diagnose Chittering Insects": hvc.happiness = 45
                case "Diagnose Fleshy Hellscape":   hvc.happiness = 2
                default: hvc.happiness = 50
                }
            }
        }
    }
    
}

