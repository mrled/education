//
//  PlaceholderButton.swift
//  StanfordCalculator
//
//  Created by Micah R Ledbetter on 2015-07-12.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

@IBDesignable
class PlaceholderButton: UIButton {
    override var backgroundColor: UIColor? {
        get {
            #if TARGET_INTERFACE_BUILDER
                return self.currentTitleColor
            #else
                return super.backgroundColor
            #endif
        }
        set {
            super.backgroundColor = backgroundColor
        }
    }
}
