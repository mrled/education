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
        let brickHitMax = Defaults.objectForKey(DefaultsKey.BrickMaxHitCount, withDefault: AppConstants.BrickMaxHitCountDefault)
        brickHitMaxLabel.text = "Max brick hits: \(brickHitMax)"
        brickHitMaxStepper.value = Double(brickHitMax)
        brickHitMaxStepper.minimumValue = 1
        brickHitMaxStepper.maximumValue = Double(AppConstants.BrickMaxHitCountMax)
    }}
    @IBOutlet weak var brickHitMaxLabel: UILabel!
    @IBAction func brickHitMaxValueChanged(sender: UIStepper) {
        brickHitMaxLabel.text = "Max brick hits: \(Int(brickHitMaxStepper.value))"
        Defaults.setObject(Int(brickHitMaxStepper.value), forKey: DefaultsKey.BrickMaxHitCount)
    }
    
    @IBOutlet weak var rowCountLabel: UILabel!
    @IBOutlet weak var rowCountStepper: UIStepper! { didSet {
        let rowCount = Defaults.objectForKey(DefaultsKey.BrickRowCount, withDefault: AppConstants.BrickRowCountDefault)
        rowCountLabel.text = "Row count: \(rowCount)"
        rowCountStepper.value = Double(rowCount)
        rowCountStepper.minimumValue = 1
        rowCountStepper.maximumValue = Double(AppConstants.BrickRowCountMax)
    }}
    @IBAction func rowCountValueChanged(sender: UIStepper) {
        rowCountLabel.text = "Row count: \(Int(rowCountStepper.value))"
        Defaults.setObject(Int(rowCountStepper.value), forKey: DefaultsKey.BrickRowCount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
