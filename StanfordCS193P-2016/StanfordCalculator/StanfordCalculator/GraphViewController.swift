//
//  GraphViewController.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-07-21.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {

    @IBOutlet weak var graphView: GraphView! {
        didSet {
            let pinchGest = UIPinchGestureRecognizer(
                target: graphView,
                action: "scaleFromPinch:")
            graphView.addGestureRecognizer(pinchGest)
            let panGest = UIPanGestureRecognizer(
                target: graphView,
                action: "orientFromPan:")
            graphView.addGestureRecognizer(panGest)
            
            graphView.dataSource = self
        }
    }
    
    var brain: CalculatorBrain?
    func getGraphingBrain() -> CalculatorBrain? {
        return self.brain
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        graphView?.setNeedsDisplay()
    }
}
 