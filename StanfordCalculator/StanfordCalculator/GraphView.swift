//
//  GraphView.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-07-21.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class GraphView: UIView {
    
    private struct Constants {
        static let InitialPPU: CGFloat = 50
        static let InitialCenter = CGPoint(x: 50, y: 50)
    }

    var centerInMyCoords: CGPoint {
        return self.convertPoint(self.center, fromCoordinateSpace: self.superview!)
    }

    var axesArtist = AxesDrawer()
    
    /*
    // Original implementation (no panning):
    var axesOrigin: CGPoint {
        return self.convertPoint(self.center, fromCoordinateSpace: self.superview!)
    }

    //This works:
    var axesOrigin: CGPoint = CGPoint(x: 50, y: 50) {
        didSet { self.setNeedsDisplay() }
    }
    
    // This doesnt:
    var initialCenter = self.convertPoint(self.center, fromCoordinateSpace: self.superview!)
    var axesOrigin: CGPoint = self.initialCenter {
        didSet { self.setNeedsDisplay() }
    }
    
    // This also doesnt: 
    var axesOrigin: CGPoint = self.centerInMyCoords {
        didSet { self.setNeedsDisplay() }
    }
    
    // This works but means I have to keep a dumb InitialCenter constant around:
    var axesOrigin: CGPoint = Constants.InitialCenter {
        didSet { self.setNeedsDisplay() }
    }
    */
    
    // ... and of course this works but means I have to keep an explicit backing variable around:
    var _axesOrigin: CGPoint?
    var axesOrigin: CGPoint {
        get {
            if let ao = self._axesOrigin { return ao }
            else { return self.centerInMyCoords }
        }
        set {
            self._axesOrigin = newValue
            self.setNeedsDisplay()
        }
    }
    
    var axesPPU: CGFloat = Constants.InitialPPU {
        didSet { self.setNeedsDisplay() }
    }
    
    func scaleFromPinch(gesture: UIPinchGestureRecognizer) {
        if ((gesture.state != .Changed) && (gesture.state != .Ended)) { return }
        self.axesPPU *= gesture.scale
        gesture.scale = 1
    }
    
    func orientFromPan(gesture: UIPanGestureRecognizer) {
        if ((gesture.state != .Changed) && (gesture.state != .Ended)) { return }
        let translation = gesture.translationInView(self)
        axesOrigin.x += translation.x
        axesOrigin.y += translation.y
        gesture.setTranslation(CGPointZero, inView: self)
    }

    override func drawRect(rect: CGRect) {
        axesArtist.drawAxesInRect(rect, origin: axesOrigin, pointsPerUnit: axesPPU)
    }
}
