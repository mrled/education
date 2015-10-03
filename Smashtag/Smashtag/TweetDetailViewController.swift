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
            if tweet.urls.count > 0 {
                var urls = [TweetDetailItem]()
                for url in tweet.urls {
                    urls.append(TweetDetailItem(type: .Url, textData: url.keyword))
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
//        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // TODO: why do I need this wtf
    override func tableView(
        tableView: UITableView,
        estimatedHeightForRowAtIndexPath indexPath: NSIndexPath)
        -> CGFloat
    {
        
        let rowData = tweetDetails[indexPath.section][indexPath.row]
        switch rowData.type {

        case .Media:
            /*
            - set a max height value. 1/2 the screen? # of pixels? somethin like that
            - set a min height value - actually this should just be the default row height or w/e
            - if image is over the max
              - scale it down til it hits the max HEIGHT, keeping aspect ratio
            - if it's under the min
              - scale it up til it hits the max WIDTH, keeping aspect ratio
            - if it's between the two
              - display it as is
            - center it in the view
            - TODO: tweets with multiple images?
*/
            return UITableViewAutomaticDimension

        default:
            return UITableViewAutomaticDimension
        }
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
            if let url = NSURL(string: row.textData) {
                ImageCache.fetchImageWithURL(url, debugging: true) {
                    (image: UIImage) -> () in
                    cell.cellImage = image
                }
            }
            
            return cell

        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(IBConstants.TweetDetailTextItemCell, forIndexPath: indexPath) as! TweetDetailTextCell
            cell.cellText = row.textData
            return cell
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
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
