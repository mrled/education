//
//  TweetDetailViewCell.swift
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-09-14.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class TweetDetailMediaCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    var cellText: String? { didSet { label.text = cellText } }
    var cellImage: UIImage?
}
class TweetDetailTextCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    var cellText: String? { didSet { label.text = cellText } }
}
//class TweetDetailTweetTextCell: UITableViewCell {
//    @IBOutlet weak var label: UILabel!
//    var cellText: String? { didSet { label.text = cellText } }
//}
