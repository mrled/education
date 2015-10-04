//
//  TweetDetailViewCell.swift
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-09-14.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class TweetDetailMediaCell: UITableViewCell {
    @IBOutlet weak var mediaView: UIImageView!
    @IBOutlet weak var label: UILabel!
    var imageScale: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    var cellText: String? {
        didSet {
            label.text = cellText

            guard let cellText = cellText, let url = NSURL(string: cellText) else { return }

            ImageCache.fetchImageWithURL(url, debugging: true) {
                (image: UIImage) -> () in
                self.cellImage = image
            }

        }
    }
    var cellImage: UIImage? {
        didSet {
            mediaView.image = cellImage
            mediaView.setNeedsDisplay()
            if cellImage != nil {
                label.hidden = true
                mediaView.hidden = false
            }
            else {
                label.hidden = false
                mediaView.hidden = true
            }
        }
    }
}
class TweetDetailTextCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    var cellText: String? { didSet { label.text = cellText } }
}
