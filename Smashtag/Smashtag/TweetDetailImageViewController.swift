//
//  TweetDetailImageViewController.swift
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-10-04.
//  Copyright © 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class TweetDetailImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            self.setupScrollingImage()
            scrollView.delegate = self
        }
    }
    
    var imageView: UIImageView?
    var image: UIImage? { didSet { self.setupScrollingImage() }}
    
    func setupScrollingImage() {
        self.imageView = nil
        guard let scrollView = self.scrollView else { return }
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        guard let image = self.image else { return }
        self.imageView = UIImageView(image: image)
        scrollView.addSubview(self.imageView!)
        scrollView.contentSize = self.imageView!.bounds.size
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2.0
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
