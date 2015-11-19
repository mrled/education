//
//  ViewController.swift
//  OutBreak
//
//  Created by Micah R Ledbetter on 2015-11-18.
//  Copyright © 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // - MARK: Outlets
    
    @IBOutlet weak var gameView: GameView!
    
    // - MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(gravity)
        animator.addBehavior(collider)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if paddle == nil { addPaddle() }
        if bricks == nil { addBricks() }
        if ball == nil { addBall() }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // - MARK: Animation
    
    lazy var animator: UIDynamicAnimator = { return UIDynamicAnimator(referenceView: self.gameView) }()
    
    lazy var collider: UICollisionBehavior = {
        let lazyColi = UICollisionBehavior()
        lazyColi.translatesReferenceBoundsIntoBoundary = true
        return lazyColi
    }()
    
    let gravity = UIGravityBehavior()
    
    // - MARK: Constants
    
    struct Constants {
        static let PaddleSize = CGSize(width: 80, height: 20)
        static let BrickSize  = CGSize(width: 40, height: 20)
        static let BallSize   = CGSize(width: 20, height: 20)
        static let PaddleColor = UIColor.grayColor()
        static let BrickColor  = UIColor.blueColor()
        static let BallColor   = UIColor.greenColor()
        static let BrickBorderColor = UIColor.blackColor().CGColor
    }
    
    // - MARK: Game UI
    
    var ball: UIView?
    var paddle: UIView?
    var bricks: [UIView]?

    func addPaddle() {
        let newPaddle = UIView(frame: CGRect(origin: CGPoint.zero, size: Constants.PaddleSize))
        newPaddle.center = CGPoint(
            x: gameView.center.x,
            y: gameView.bounds.height - (Constants.BrickSize.height * CGFloat(0.5) ))
        newPaddle.backgroundColor = Constants.PaddleColor
        gameView.addSubview(newPaddle)
        collider.addItem(newPaddle)
        paddle = newPaddle
    }
    
    func addBricks() {
        let newBricks = [UIView]()
        for brick in newBricks {
            // gameView.center = ???
            brick.backgroundColor = Constants.BrickColor
            brick.layer.borderColor = Constants.BrickBorderColor
            collider.addItem(brick)
            gameView.addSubview(brick)
        }
        bricks = newBricks
    }
    
    func addBall() {
        let newBall = UIView(frame: CGRect(origin: CGPoint.zero, size: Constants.BallSize))
        newBall.center = CGPoint(
            x: gameView.center.x,
            y: gameView.center.y + (Constants.BallSize.height * 5))
        newBall.backgroundColor = Constants.BallColor
        gameView.addSubview(newBall)
        gravity.addItem(newBall)
        collider.addItem(newBall)
        ball = newBall
    }

}

