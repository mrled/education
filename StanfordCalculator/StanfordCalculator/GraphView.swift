//
//  GraphView.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-07-21.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class GraphView: UIView {
    
    var axesArtist = AxesDrawer()

    override func drawRect(rect: CGRect) {
        axesArtist.drawAxesInRect(rect,
            origin: self.convertPoint(self.center,
                fromCoordinateSpace: self.superview!),
            pointsPerUnit: 1)
    }
    

}
