//
//  DiagHistoryVC.swift
//  Psychologist
//
//  Created by Micah R Ledbetter on 2015-06-29.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class DiagHistoryVC: UIViewController {
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.text = text
        }
    }
    var text: String = "" {
        didSet {
            textView?.text = text
        }
    }
    override var preferredContentSize: CGSize {
        get {
            if textView != nil && presentingViewController != nil {
                return textView.sizeThatFits(presentingViewController!.view.bounds.size)
            }
            else {
                return super.preferredContentSize
            }
        }
        set {super.preferredContentSize = newValue}
    }
}
