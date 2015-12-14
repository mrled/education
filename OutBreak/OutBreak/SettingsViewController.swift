//
//  SettingsViewController.swift
//  OutBreak
//
//  Created by Micah R Ledbetter on 2015-12-09.
//  Copyright © 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var enableBallTapping: UISwitch!
    @IBOutlet weak var brickHitMaxStepper: UIStepper! { didSet {
        let brickHitMax = Defaults.objectForKey(DefaultsKey.BrickMaxHitCount, withDefault: 2)
        let labelText = "Max brick hits: \(brickHitMax)"
        print(labelText)
        brickHitMaxLabel.text = labelText
        brickHitMaxStepper.value = Double(brickHitMax)
    }}
    @IBOutlet weak var brickHitMaxLabel: UILabel!
    
    @IBAction func brickHitMaxValueChanged(sender: UIStepper) {
        //let labelText = "Max brick hits: \(Int(brickHitMaxStepper.value))"
        //print(labelText)
        //brickHitMaxLabel.text = labelText
        let labelText = "Max brick hits: \(Int(brickHitMaxStepper.value))"
        print(labelText)
        brickHitMaxLabel.text = labelText
        Defaults.setObject(Int(brickHitMaxStepper.value), forKey: DefaultsKey.BrickMaxHitCount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
