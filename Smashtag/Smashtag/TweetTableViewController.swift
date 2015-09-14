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
        static let DefaultTwitterSearch: String = "xcode"
        static let TweetCellReuseId: String = "TweetCell"
    }
    
    @IBOutlet weak var searchField: UITextField!
    var searchText: String? = Constants.DefaultTwitterSearch {
        didSet {
            tweets.removeAll()
            tableView.reloadData()
            lastSuccessfulRequest = nil
            refresh()
        }
    }
    var tweets = [[Tweet]]()
    //var userImageCache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
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
        println("MARK - Refreshing...")
        refreshControl?.beginRefreshing()
        if let request = nextRequest {
            request.fetchTweets {
                (newTweets) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    () -> Void in
                    println("Found \(newTweets.count) new tweets")
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
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TweetCellReuseId, forIndexPath: indexPath) as! TweetTableViewCell
        //cell.tableViewController = self
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
