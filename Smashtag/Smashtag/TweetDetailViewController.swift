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

class TweetDetailViewController: UITableViewController {

    @IBOutlet weak var navItem: UINavigationItem!

    var tweet: Tweet? {
        didSet { navItem.title = "Tweet Detail" }
    }
    
    var tweetDetails: [[TweetDetailItem]] {
        var td = [[TweetDetailItem]]()
        if let tweet = self.tweet {
            let potentialNewSections =  [
                [TweetDetailItem(type: .TweetText, textData: tweet.text)],
                tweet.media.map         { TweetDetailItem(type: .Media,   textData: "\($0.url)", mediaData: $0) },
                tweet.hashtags.map      { TweetDetailItem(type: .Hashtag, textData: $0.keyword) },
                tweet.expanded_urls.map { TweetDetailItem(type: .Url,     textData: $0) },
                tweet.userMentions.map  { TweetDetailItem(type: .Mention, textData: $0.keyword) }]
            for potential in potentialNewSections {
                if potential.count > 0 { td.append(potential) }
            }
        }
        return td
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
    
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        //TODO: Seems like it would be better to refactor the TweetDetailItemType enum to hold on to these labels itself
        switch tweetDetails[section][0].type {
        case .Hashtag:   return "Hashtags"
        case .Media:     return "Media"
        case .Mention:   return "Mentions"
        case .Url:       return "URLs"
        case .TweetText: return "Tweet"
        }
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
            let indexSet = NSIndexSet.init(index: indexPath.section)
            if let url = NSURL(string: row.textData) {
                ImageCache.fetchImageWithURL(url, debugging: true) {
                    image in
                    // Only do reloadSections() if the image isn't already set, to prevent an endless loop
                    if cell.cellImage != image {
                        cell.cellImage = image
                        // For some reason, tableView.reloadData() does NOT get the desired effect but reloadSections() does??
                        self.tableView.reloadSections(indexSet, withRowAnimation: .None)
                    }
                }
            }
            return cell

        case .Hashtag:
            let cell = tableView.dequeueReusableCellWithIdentifier(IBConstants.TweetDetailHashtagCell, forIndexPath: indexPath) as! TweetDetailTextCell
            cell.cellText = row.textData
            return cell
            
        case .Url:
            let cell = tableView.dequeueReusableCellWithIdentifier(IBConstants.TweetDetailUrlCell, forIndexPath: indexPath) as! TweetDetailTextCell
            cell.cellText = row.textData
            return cell
            
        case .Mention:
            let cell = tableView.dequeueReusableCellWithIdentifier(IBConstants.TweetDetailMentionCell, forIndexPath: indexPath) as! TweetDetailTextCell
            cell.cellText = row.textData
            return cell

        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
 
        switch identifier {

        case IBConstants.DetailImageSegueId:
            print(IBConstants.DetailImageSegueId)
            guard let cell = tableView.cellForRowAtIndexPath(selectedIndexPath) as? TweetDetailMediaCell else { return }
            guard let img = cell.cellImage else { return }
            let destination = unwrapNavigationControllerForSegue(segue, ofType: TweetDetailImageViewController())
            destination?.image = img

        case IBConstants.SearchFromDetailSegueId:
            guard let cell = tableView.cellForRowAtIndexPath(selectedIndexPath) as? TweetDetailTextCell else { return }
            let destination = unwrapNavigationControllerForSegue(segue, ofType: TweetTableViewController())
            destination?.searchText = cell.cellText

        default:
            return
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tweetDetails[indexPath.section][indexPath.row]
        
        switch cell.type {
        case .Url:
            guard let url = NSURL(string: cell.textData) else { return }
            let svc = SFSafariViewController(URL: url)
            presentViewController(svc, animated: true, completion: nil)
        default:
            return
        }
    }
}
