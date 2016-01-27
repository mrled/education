//
//  Constants.swift
//  OutBreak
//
//  Created by Micah R Ledbetter on 2015-12-09.
//  Copyright © 2015 Micah R Ledbetter. All rights reserved.
//

import Foundation


struct AppConstants {
    static let PaddleBoundaryId = "Paddle"
    static let LeftSideBoundaryId = "LeftSide"
    static let RightSideBoundaryId = "RightSide"
    static let TopSideBoundaryId = "TopSide"
    static let BottomSideBoundaryId = "BottomSide"
    static let BrickMaxHitCountDefault = 2
    static let BrickMaxHitCountMax = 4
    static let BrickRowCountDefault = 6
    static let BrickRowCountMax = 8
    static let BallIsTappableDefault = true
}

struct DefaultsKey {
    static let BrickMaxHitCount = "BrickMaxHitCount"
    static let BrickRowCount = "BrickRowCount"
    static let BallIsTappable = "BallIsTappable"
}
