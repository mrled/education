//
//  DiagnosisViewController.swift
//  Psychologist
//
//  Created by Micah R Ledbetter on 2015-06-23.
//  Copyright (c) 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class DiagnosisViewController: UIViewController, FaceViewDataSource {
    
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.dataSource = self
        }
    }
    
    var happiness: Int = 60 { // 0 is saddest, 100 is happiest
        didSet {
            let tryHappiness = happiness
            happiness = min(max(happiness, 0), 100)
            println("Trynna set happiness to \(tryHappiness), actually settin happiness to \(happiness)")
            updateUI()
        }
    }
    
    private func updateUI() {
        faceView?.setNeedsDisplay()
    }
    
    func smilinessForFaceView(sender: FaceView) -> Double? {
        return Double(happiness - 50)/50
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
