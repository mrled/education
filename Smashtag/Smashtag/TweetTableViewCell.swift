//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-09-07.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    struct Constants {
        static let ImageDownloadQueueName = "ImageDownloadQueue" // TODO: test w/ a serial queue w/ this name/
        static let TweetHashtagColor = UIColor.lightGrayColor()
        static let TweetMentionColor = UIColor.magentaColor()
        static let TweetUrlColor = UIColor.blueColor()
    }

    @IBOutlet weak var userField: UILabel!
    @IBOutlet weak var tweetField: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var tweet: Tweet? { didSet { updateUI() } }
    
    func updateUI() {
        userField.text = nil
        tweetField.text = nil
        userImageView.image = nil
        guard let tweet = self.tweet else { return }

        let attributedTweet = NSMutableAttributedString(string: tweet.text)
        for hashtag in tweet.hashtags {
            attributedTweet.addAttribute(
                NSForegroundColorAttributeName,
                value: Constants.TweetHashtagColor,
                range: hashtag.nsrange)
        }
        for url in tweet.urls {
            attributedTweet.addAttribute(
                NSForegroundColorAttributeName,
                value: Constants.TweetUrlColor,
                range: url.nsrange)
        }
        for mention in tweet.userMentions {
            attributedTweet.addAttribute(
                NSForegroundColorAttributeName,
                value: Constants.TweetMentionColor,
                range: mention.nsrange)
        }
        
        tweetField.attributedText = attributedTweet
        userField.text = "\(tweet.user)"
        
        if let userImageUrl = tweet.user.profileImageURL {
            ImageCache.fetchImageWithURL(userImageUrl) {
                (image: UIImage) -> () in
                self.userImageView.image = image
                self.userImageView.setNeedsDisplay()
            }
        }
    }
}
