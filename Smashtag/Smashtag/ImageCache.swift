//
//  ImageCache.swift
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-09-13.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class ImageCache: NSCache {
    static let sharedManager = ImageCache()
    
    private var observer: NSObjectProtocol!
    
    override init() {
        super.init()
        
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidReceiveMemoryWarningNotification, object: nil, queue: nil) { [unowned self] notification in
            self.removeAllObjects()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
}
