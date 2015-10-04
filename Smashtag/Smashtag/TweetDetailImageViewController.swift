//
//  TweetDetailImageViewController.swift
//  Smashtag
//
//  Created by Micah R Ledbetter on 2015-10-04.
//  Copyright © 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class TweetDetailImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: TweetDetailImageView! {
        didSet {
            imageView.image = self.image
        }
    }
    var image: UIImage? {
        didSet {
            imageView?.image = image
            imageView?.setNeedsDisplay()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
