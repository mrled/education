//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-09-03.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    struct Constants {
        static let DefaultTwitterSearch: String = "MicahXcodeTest"
    }
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var searchField: UITextField!
    
    var searchText: String? {
        didSet {
            navItem.title = "Search: \(Constants.DefaultTwitterSearch)"
            tweets.removeAll()
            tableView.reloadData()
            lastSuccessfulRequest = nil
            refresh()
        }
    }
    var tweets = [[Tweet]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchText = Constants.DefaultTwitterSearch
        searchField.delegate = self
        tableView.estimatedRowHeight = tableView.rowHeight  // magic
        tableView.rowHeight = UITableViewAutomaticDimension
        searchField.text = Constants.DefaultTwitterSearch
        refresh()
    }
    
    var lastSuccessfulRequest: TwitterRequest?
    var nextRequest: TwitterRequest? {
        if let lsr = lastSuccessfulRequest {
            return lsr.requestForNewer
        }
        else {
            if let st = searchText {
                return TwitterRequest(search: st, count: 100)
            }
            else {
                return nil
            }
        }
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        if let request = nextRequest {
            request.fetchTweets {
                (newTweets) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    () -> Void in
                    print("Found \(newTweets.count) new tweets")
                    if newTweets.count > 0 {
                        self.lastSuccessfulRequest = request
                        self.tweets.insert(newTweets, atIndex: 0)
                        self.tableView.reloadData()
                    }
                    self.refreshControl?.endRefreshing()
                }
            }
        }
        else {
            refreshControl?.endRefreshing()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = searchField.text
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(IBConstants.TweetCellReuseId, forIndexPath: indexPath) as! TweetTableViewCell
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {

            switch identifier {

            case IBConstants.DetailSegueId:

                var destination: TweetDetailViewController?
                if let navCon = segue.destinationViewController as? UINavigationController {
                    if let detailVC = navCon.visibleViewController as? TweetDetailViewController {
                        destination = detailVC
                    }
                }
                else if let detailVC = segue.destinationViewController as? TweetDetailViewController {
                    destination = detailVC
                }

                if let destination = destination {
                    if let selectedIndexPath = tableView.indexPathForSelectedRow {
                        if let cell = tableView.cellForRowAtIndexPath(selectedIndexPath) as? TweetTableViewCell {
                            destination.tweet = cell.tweet
                        }
                    }
                }

            default: return
            }
        }
    }
}
