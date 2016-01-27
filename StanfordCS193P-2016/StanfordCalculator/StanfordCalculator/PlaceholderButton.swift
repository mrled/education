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
    var placeholderBackgroundColor: UIColor { return self.currentTitleColor }
    @IBInspectable var isPlaceholder: Bool = false {
        willSet {
            #if TARGET_INTERFACE_BUILDER
                if newValue == true {
                    self.backgroundColor = self.placeholderBackgroundColor
                }
            #endif
        }
    }
}
