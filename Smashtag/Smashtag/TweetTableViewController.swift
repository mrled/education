//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-09-03.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    struct Constants {
        //static let DefaultTwitterSearch: String = "MicahXcodeTest"
        static let DefaultTwitterSearch: String = "xcode"
    }
    
    @IBOutlet weak var navItem: UINavigationItem! { didSet { navItem.title    = navItemTitle }}
    @IBOutlet weak var searchField:  UITextField! { didSet { searchField.text = searchFieldText }}

    var searchText: String? {
        didSet {
            if let searchText = searchText {
                if let idx = searchTextHistory.indexOf(searchText) {
                    searchTextHistory.removeAtIndex(idx)
                }
                searchTextHistory += [searchText]
            }
            navItem?.title = navItemTitle
            searchField?.text = searchFieldText
            tweets.removeAll()
            tableView?.reloadData()
            lastSuccessfulRequest = nil
            refresh()
        }
    }
    var searchTextHistory: [String] {
        get { return defaults.objectForKey(GlobalConstants.HistoryDefaultsKey) as? [String] ?? [] }
        set { defaults.setObject(newValue, forKey: GlobalConstants.HistoryDefaultsKey) }
    }
    var searchFieldText: String { return searchText == nil ? "" : searchText! }
    var navItemTitle:    String { return searchText == nil ? "" : "Search: \(searchText!)" }

    var tweets = [[Tweet]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if searchText == nil {
            searchText = Constants.DefaultTwitterSearch
        }
        searchField.delegate = self
        tableView.estimatedRowHeight = tableView.rowHeight  // magic
        tableView.rowHeight = UITableViewAutomaticDimension
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
        guard let request = nextRequest else {
            refreshControl?.endRefreshing()
            return
        }
        
        request.fetchTweets {
            newTweets in
            dispatch_async(dispatch_get_main_queue()) {
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
        let cell = tableView.dequeueReusableCellWithIdentifier(GlobalConstants.TweetCellReuseId, forIndexPath: indexPath) as! TweetTableViewCell
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {

            switch identifier {

            case GlobalConstants.DetailSegueId:
                let destination = unwrapNavigationControllerForSegue(segue, ofType: TweetDetailViewController())
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    if let cell = tableView.cellForRowAtIndexPath(selectedIndexPath) as? TweetTableViewCell {
                        destination?.tweet = cell.tweet
                    }
                }

            default: return
            }
        }
    }
}
