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
struct TweetDetailItem {
    var type: TweetDetailItemType
    var textData: String
}
struct TweetDetailSection {
    var type: TweetDetailItemType
    var items: [TweetDetailItem]
}

class TweetDetailViewController: UITableViewController {

    @IBOutlet weak var navItem: UINavigationItem!

    var tweet: Tweet? {
        didSet { navItem.title = "Tweet Detail" }
    }
    
    var tweetDetails: [TweetDetailSection] {
        var td = [TweetDetailSection]()
        if let tweet = self.tweet {
            let textItem = TweetDetailItem(type: .TweetText, textData: tweet.text)
            td.append(TweetDetailSection(type: .TweetText, items: [textItem]))
            if tweet.hashtags.count > 0 {
                var hashtags = [TweetDetailItem]()
                for hashtag in tweet.hashtags {
                    hashtags.append(TweetDetailItem(type: .Hashtag, textData: hashtag.keyword))
                }
                td.append(TweetDetailSection(type: .Hashtag, items: hashtags))
            }
            if tweet.media.count > 0 {
                var medias = [TweetDetailItem]()
                for medium in tweet.media {
                    medias.append(TweetDetailItem(type: .Media, textData: "\(medium.url)"))
                }
                td.append(TweetDetailSection(type: .Media, items: medias))
            }
            if tweet.userMentions.count > 0 {
                var mentions = [TweetDetailItem]()
                for mention in tweet.userMentions {
                    mentions.append(TweetDetailItem(type: .Mention, textData: mention.keyword))
                }
                td.append(TweetDetailSection(type: .Mention, items: mentions))
            }
            if tweet.urls.count > 0 {
                var urls = [TweetDetailItem]()
                for url in tweet.urls {
                    urls.append(TweetDetailItem(type: .Url, textData: url.keyword))
                }
                td.append(TweetDetailSection(type: .Url, items: urls))
            }
        }
        return td
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.estimatedRowHeight = tableView.rowHeight  // magic
//        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // TODO: why do I need this wtf
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweetDetails.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetDetails[section].items.count
    }
    
    override func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        
        let section = tweetDetails[indexPath.section]
        let sectionText = section.items[indexPath.row].textData
        
        switch section.type {
        case .TweetText:
            let cell = tableView.dequeueReusableCellWithIdentifier(IBConstants.TweetCellReuseId, forIndexPath: indexPath) as! TweetTableViewCell
            cell.tweet = tweet
            return cell
        case .Media:
            let cell = tableView.dequeueReusableCellWithIdentifier(IBConstants.TweetDetailMediaItemCell, forIndexPath: indexPath) as! TweetDetailMediaCell
            print("Found a media section!")
            cell.cellText = sectionText
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(IBConstants.TweetDetailTextItemCell, forIndexPath: indexPath) as! TweetDetailTextCell
            cell.cellText = sectionText
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
        let section = tweetDetails[indexPath.section]
        let cell = section.items[indexPath.row]
        
        switch section.type {
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
