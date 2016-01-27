//
//  GraphView.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-07-21.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func getGraphingBrain() -> CalculatorBrain?
}


/* NOTES
- "graph view": a UIView subclass responsible for the graph, where points are analogous to pixels (though retina complicates this)
- "graph plot": the graph's x,y coordinate system, where X is a variable and Y is the output for a given X. This does NOT coorespond directly to a UIView!
*/


class GraphView: UIView {

    private struct Constants {
        static let InitialPPU: CGFloat = 20
        static let InitialCenter = CGPoint(x: 0, y: 0)
        static let CalcBrainMemId = "M"
        static let PointsToDraw = 50.0
        static let GraphLineColor = UIColor.orangeColor()
    }

    var centerInOwnCoords: CGPoint {
        if let sv = self.superview {
            return self.convertPoint(self.center, fromCoordinateSpace: sv)
        }
        else {
            return Constants.InitialCenter
        }
    }

    var axesArtist = AxesDrawer()
    
    weak var dataSource: GraphViewDataSource?
    
    
    //MARK: Graph Plot stuff {
    private var _plotOriginInViewCoordinates: CGPoint?
    var plotOriginInViewCoordinates: CGPoint {
        get {
            if let ao = self._plotOriginInViewCoordinates { return ao }
            else { return self.centerInOwnCoords }
        }
        set {
            self._plotOriginInViewCoordinates = newValue
            self.setNeedsDisplay()
        }
    }
    
    // The AxesDrawer class calls this exact concept "points per unit", but that name doesn't disambiguate a damn thing
    var viewPointsPerPlotPoint: CGFloat = Constants.InitialPPU {
        didSet { self.setNeedsDisplay() }
    }
    
    var plotRect: CGRect {
        let plotVisibleSize = CGSize(
            width:  self.bounds.size.width  / self.viewPointsPerPlotPoint,
            height: self.bounds.size.height / self.viewPointsPerPlotPoint)
        
        // We want this to be the lowest-most, left-most VISIBLE point in the plot's coordinate system
        let plotPointAtLowerLeft = CGPoint(
            x: -(self.plotOriginInViewCoordinates.x / viewPointsPerPlotPoint ),
            // The "self.bounds.maxY - ..."  because the UIView's coordinate space has a FLIPPED Y AXIS and we have to reverse this
            y: -((self.bounds.maxY - self.plotOriginInViewCoordinates.y) / viewPointsPerPlotPoint))
        
        let myRect = CGRect(origin: plotPointAtLowerLeft, size: plotVisibleSize)
        //println("Visible size: \(plotVisibleSize); Plot point at lower left: \(plotPointAtLowerLeft); minX/maxX/minY/maxY: \(myRect.minX)/\(myRect.maxX)/\(myRect.minY)/\(myRect.maxY)")
        return myRect
    }
    
    private func viewCoordinatesForPlotPoint(point: CGPoint) -> CGPoint {
        return CGPoint(
            x:  (point.x * viewPointsPerPlotPoint) + plotOriginInViewCoordinates.x,
            y: -(point.y * viewPointsPerPlotPoint) + plotOriginInViewCoordinates.y)
    }
    //MARK: }
    
    //MARK: Gesture handling {
    func scaleFromPinch(gesture: UIPinchGestureRecognizer) {
        if ((gesture.state != .Changed) && (gesture.state != .Ended)) { return }
        self.viewPointsPerPlotPoint *= gesture.scale
        gesture.scale = 1
    }
    
    func orientFromPan(gesture: UIPanGestureRecognizer) {
        if ((gesture.state != .Changed) && (gesture.state != .Ended)) { return }
        let translation = gesture.translationInView(self)
        self.plotOriginInViewCoordinates.x += translation.x
        self.plotOriginInViewCoordinates.y += translation.y
        gesture.setTranslation(CGPointZero, inView: self)
    }
    //MARK: }

    override func drawRect(rect: CGRect) {
        
        axesArtist.drawAxesInRect(rect,
            origin: self.plotOriginInViewCoordinates,
            pointsPerUnit: self.viewPointsPerPlotPoint)
        
        if let brain = dataSource?.getGraphingBrain() {
            
            var color = Constants.GraphLineColor
            color.set()
            let path = UIBezierPath()
            
            var lastValidPoint: CGPoint?
            let oldMemoryValue = brain.retrieveVariable(Constants.CalcBrainMemId)

            for var x  = Double(self.plotRect.minX);
                    x <= Double(self.plotRect.maxX);
                    x += Double(self.plotRect.width) / Constants.PointsToDraw
            {
                //var msg = "\(x) -> M; "
                if let y = brain.assignVariable(Constants.CalcBrainMemId, value: x) {
                    let plotPoint = CGPoint(x:x, y:y)
                    let plotPointInView = viewCoordinatesForPlotPoint(plotPoint)
                    //msg += "plotPoint: \(plotPoint); plotPointInView: \(plotPointInView); self.bounds: \(self.bounds); "
                    if lastValidPoint != nil {
                        path.addLineToPoint(plotPointInView) }
                    else {
                        path.moveToPoint(plotPointInView) }
                    lastValidPoint = plotPointInView
                }
                else {
                    //msg += "No Y result for this M"
                    lastValidPoint = nil
                }
                //println(msg)
            }
            path.stroke()
            brain.assignVariable(Constants.CalcBrainMemId, value: oldMemoryValue)
        }
    }
}
