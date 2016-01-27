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
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let selectedCell = tableView.cellForRowAtIndexPath(indexPath) else { logFailedGuard(); return }
        guard let cellText = selectedCell.textLabel?.text else { logFailedGuard(); return }
        guard let tabBC = self.tabBarController else { logFailedGuard(); return }
        guard let navVC = tabBC.viewControllers?[0] as? UINavigationController else { logFailedGuard(); return }
        guard let searchVC = navVC.visibleViewController as? TweetTableViewController else { logFailedGuard(); return }
        searchVC.searchText = cellText
        tabBC.selectedIndex = 0
    }
    
    // MARK: - Navigation

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        guard let identifier = segue.identifier else { return }
//        switch identifier {
//        case GlobalConstants.SearchFromHistoryTabSegueId:
//            
//            guard let tabBC = segue.destinationViewController as? SmashtagTabBarController else { logFailedGuard(); return }
//            guard let navVC = tabBC.viewControllers?[0] as? UINavigationController else { logFailedGuard(); return }
//            guard let searchVC = navVC.visibleViewController as? TweetTableViewController else { logFailedGuard(); return }
//            
//            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { logFailedGuard(); return }
//            guard let selectedCell = tableView.cellForRowAtIndexPath(selectedIndexPath) else { logFailedGuard(); return }
//            guard let cellText = selectedCell.textLabel?.text else { logFailedGuard(); return }
//            
//            searchVC.searchText = cellText
//            //tabBC.selectedViewController = navVC
//            tabBC.selectedIndex = 0
//            
//        default:
//            return
//        }
//
//    }

}
