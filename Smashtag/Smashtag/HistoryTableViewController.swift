//
//  HistoryTableViewController.swift
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-10-28.
//  Copyright © 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var searchHistory: [String] {
        get { return defaults.objectForKey(GlobalConstants.HistoryDefaultsKey) as? [String] ?? [] }
        set { defaults.setObject(newValue, forKey: GlobalConstants.HistoryDefaultsKey) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(GlobalConstants.SearchHistoryItemCellId, forIndexPath: indexPath)
        cell.textLabel?.text = searchHistory[indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            searchHistory.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
