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
    
    static func fetchImageWithURL(
        url: NSURL,
        debugging: Bool = false,
        callback: (image: UIImage)->() )
    {
        let cache = ImageCache.sharedManager
        if let image = cache.objectForKey(url) as! UIImage? {
            if (debugging) { print("fetchImageWithURL: Found image in cache for \(url)") }
            callback(image: image)
        }
        else {
            if (debugging) { print("fetchImageWithURL: Attempting to fetch image for \(url)") }
            let imageRequestQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
            dispatch_async(imageRequestQueue) {
                guard let imageData = NSData(contentsOfURL: url) else {
                    if (debugging) { print("fetchImageWithURL: Could not get data for \(url)") }
                    return
                }
                guard let image = UIImage(data: imageData) else {
                    if (debugging) { print("fetchImageWithURL: Could not turn data into UIImage for \(url)") }
                    return
                }
                cache.setObject(image, forKey: url)
                dispatch_async(dispatch_get_main_queue()) {
                    callback(image: image)
                }
            }
        }
    }
}
