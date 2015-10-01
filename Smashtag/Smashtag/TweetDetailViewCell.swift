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
    var cellText: String? {
        didSet {
            guard let cellText = cellText else { return }
            label.text = cellText
            if let url = NSURL(string: cellText) {
                ImageCache.fetchImageWithURL(url, debugging: true) {
                    (image: UIImage) -> () in
                    self.cellImage = image
                }
            }
        }
    }
    var cellImage: UIImage? {
        didSet {
            if let cellImage = cellImage {
                label.hidden = true
                mediaView.hidden = false
                mediaView.image = cellImage
                mediaView.setNeedsDisplay()
            }
            else {
                label.hidden = false
                mediaView.hidden = true
            }
            self.setNeedsDisplay()
        }
    }
}
class TweetDetailTextCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    var cellText: String? { didSet { label.text = cellText } }
}
//class TweetDetailTweetTextCell: UITableViewCell {
//    @IBOutlet weak var label: UILabel!
//    var cellText: String? { didSet { label.text = cellText } }
//}
