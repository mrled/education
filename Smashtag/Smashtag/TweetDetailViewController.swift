//
//  TweetDetailViewController.swift
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-09-14.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit
import SafariServices

enum TweetDetailItemType {
    case TweetText
    case Hashtag
    case Mention
    case Url
    case Media
}
class TweetDetailItem {
    var type: TweetDetailItemType
    var textData: String
    var mediaData: MediaItem?
    init(type: TweetDetailItemType, textData: String, mediaData: MediaItem? = nil) {
        self.type = type
        self.textData = textData
        self.mediaData = mediaData
    }
}

extension Tweet {
    struct TweetExtension {
        var media: [MediaItem]
        var hashtags: [String]
        var urls: [String]
        var mentions: [String]
    }
    var detailItems: TweetExtension {
        var ext: TweetExtension = TweetExtension(media: [MediaItem](), hashtags: [String](), urls: [String](), mentions: [String]())
        for medium in self.media         { ext.media.append(medium) }
        for hashtag in self.hashtags     { ext.hashtags.append(hashtag.keyword) }
        for url in self.urls             { ext.urls.append(url.keyword) }
        for mention in self.userMentions { ext.mentions.append(mention.keyword) }
        return ext
    }
}

class TweetDetailViewController: UITableViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    
    var tweetImage: UIImage?

    var tweet: Tweet? {
        didSet { navItem.title = "Tweet Detail" }
    }
    
    var tweetDetails: [[TweetDetailItem]] {
        var td = [[TweetDetailItem]]()
        if let tweet = self.tweet {
            td.append([TweetDetailItem(type: .TweetText, textData: tweet.text)])
            if tweet.media.count > 0 {
                var media = [TweetDetailItem]()
                for medium in tweet.media {
                    media.append(TweetDetailItem(type: .Media, textData: "\(medium.url)", mediaData: medium))
                }
                td.append(media)
            }
            if tweet.hashtags.count > 0 {
                var hashtags = [TweetDetailItem]()
                for hashtag in tweet.hashtags {
                    hashtags.append(TweetDetailItem(type: .Hashtag, textData: hashtag.keyword))
                }
                td.append(hashtags)
            }
//            if tweet.urls.count > 0 {
//                var urls = [TweetDetailItem]()
//                for url in tweet.urls {
//                    urls.append(TweetDetailItem(type: .Url, textData: url.keyword))
//                }
//                td.append(urls)
//            }
            if tweet.expanded_urls.count > 0 {
                var urls = [TweetDetailItem]()
                for url in tweet.expanded_urls {
                    urls.append(TweetDetailItem(type: .Url, textData: url))
                }
                td.append(urls)
            }
            if tweet.userMentions.count > 0 {
                var mentions = [TweetDetailItem]()
                for mention in tweet.userMentions {
                    mentions.append(TweetDetailItem(type: .Mention, textData: mention.keyword))
                }
                td.append(mentions)
            }
        }
        return td
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight  // magic
        //tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowData = tweetDetails[indexPath.section][indexPath.row]

        switch rowData.type {

        case .Media:
            return CGFloat(self.view.frame.height / 4)
            
        default:
            return UITableViewAutomaticDimension
        
        }
    }

    // TODO: why the fuck do I need this wtf
    override func tableView(
        tableView: UITableView,
        estimatedHeightForRowAtIndexPath indexPath: NSIndexPath)
        -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweetDetails.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetDetails[section].count
    }
    
    override func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        let row = tweetDetails[indexPath.section][indexPath.row]
        
        switch row.type {

        case .TweetText:
            let cell = tableView.dequeueReusableCellWithIdentifier(IBConstants.TweetCellReuseId, forIndexPath: indexPath) as! TweetTableViewCell
            cell.tweet = tweet
            return cell

        case .Media:
            let cell = tableView.dequeueReusableCellWithIdentifier(IBConstants.TweetDetailMediaItemCell, forIndexPath: indexPath) as! TweetDetailMediaCell
            cell.cellText = row.textData
//            if let url = NSURL(string: row.textData) {
//                ImageCache.fetchImageWithURL(url, debugging: true) {
//                    (image: UIImage) -> () in
//                    // TODO: can I do this without having to save the image in 2 places?
//                    cell.cellImage = image
//                    self.tweetImage = image
//                    self.view.setNeedsDisplay()
//                    self.tableView.setNeedsDisplay()
//                    cell.setNeedsDisplay()
//                    cell.imageView?.setNeedsDisplay()
//                }
//            }
            
            return cell

        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(IBConstants.TweetDetailTextItemCell, forIndexPath: indexPath) as! TweetDetailTextCell
            cell.cellText = row.textData
            return cell
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case IBConstants.DetailImageSegueId:
            guard let tweetImage = self.tweetImage else { return }
            var destination: TweetDetailImageViewController?
            if let navCon = segue.destinationViewController as? UINavigationController {
                if let imageVC = navCon.visibleViewController as? TweetDetailImageViewController {
                    destination = imageVC
                }
            }
            else if let imageVC = segue.destinationViewController as? TweetDetailImageViewController {
                destination = imageVC
            }
            destination?.image = tweetImage
        default:
            return
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tweetDetails[indexPath.section][indexPath.row]
        
        switch cell.type {
        case .Url:
            guard let url = NSURL(string: cell.textData) else {
                print("Bad URL")
                return
            }
            let svc = SFSafariViewController(URL: url)
            presentViewController(svc, animated: true, completion: nil)
        default:
            return
        }
    }
}
