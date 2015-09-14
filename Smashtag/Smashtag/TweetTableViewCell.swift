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
        if let tweet = self.tweet {

            var attributedTweet = NSMutableAttributedString(string: tweet.text)
            for hashtag in tweet.hashtags {
                macrolog("Found a hashtag of \(hashtag)")
                attributedTweet.addAttribute(
                    NSForegroundColorAttributeName,
                    value: Constants.TweetHashtagColor,
                    range: hashtag.nsrange)
            }
            for url in tweet.urls {
                macrolog("Found a url of \(url)")
                attributedTweet.addAttribute(
                    NSForegroundColorAttributeName,
                    value: Constants.TweetUrlColor,
                    range: url.nsrange)
            }
            for mention in tweet.userMentions {
                macrolog("Found a mention of \(mention)")
                attributedTweet.addAttribute(
                    NSForegroundColorAttributeName,
                    value: Constants.TweetMentionColor,
                    range: mention.nsrange)
            }

            tweetField.attributedText = attributedTweet
            
            let screenName = tweet.user.screenName
            userField.text = "\(tweet.user)"

            if let userImageUrl = tweet.user.profileImageURL {
                let cache = ImageCache.sharedManager
                
                // TODO: not sure this line is doing what I think it's doing...? but it does seem to be so???.
                if let image = cache.objectForKey(userImageUrl) as! UIImage? {
                    self.userImageView.image = image
                    self.userImageView.setNeedsDisplay()
                }
                else {
                    let imageRequestQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
                    dispatch_async(imageRequestQueue) {
                        if let userImageData = NSData(contentsOfURL: userImageUrl) {
                            if let userImage = UIImage(data: userImageData) {
                                cache.setObject(userImage, forKey: userImageUrl)
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.userImageView.image = userImage
                                    self.userImageView.setNeedsDisplay()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
