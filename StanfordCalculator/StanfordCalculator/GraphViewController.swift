//
//  GraphViewController.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-07-21.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    @IBOutlet weak var graphView: GraphView!
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        graphView?.setNeedsDisplay()
    }
}
 