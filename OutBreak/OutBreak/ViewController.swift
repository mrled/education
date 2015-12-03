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
    
    @IBOutlet weak var gameView: UIView!
    
    // - MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        animator.addBehavior(outBreakBehavior)

        if paddle == nil { addPaddle() }
        if bricks == nil { addBricks() }
        if ball == nil { addBall() }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        animator.removeBehavior(outBreakBehavior)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // - MARK: Gestures
    
    @IBAction func pushBall(sender: UITapGestureRecognizer) {
        guard let ball = ball else { return } 
        outBreakBehavior.pushRandomly(ball)
    }
    
    // - MARK: Animation
    
    
    lazy var animator: UIDynamicAnimator = {
        [unowned self] in
        return UIDynamicAnimator(referenceView: self.gameView)
    }()
    
    let outBreakBehavior = OutBreakBehavior()
    
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
    
    var brickColumns: Int {
        return Int(gameView.bounds.width / Constants.BrickSize.width)
    }
    var brickRows = 4
    
    func addPaddle() {
        let newPaddle = UIView(frame: CGRect(origin: CGPoint.zero, size: Constants.PaddleSize))
        newPaddle.center = CGPoint(
            x: gameView.center.x,
            y: gameView.bounds.height - (Constants.BrickSize.height * CGFloat(0.5) ))
        newPaddle.backgroundColor = Constants.PaddleColor
        gameView.addSubview(newPaddle)
        outBreakBehavior.addPaddle(newPaddle)
        paddle = newPaddle
    }
    
    func addBricks() {
        var newBricks = [UIView]()
        
        let initialBrickOriginX = ((gameView.bounds.width - (CGFloat(brickColumns) * Constants.BrickSize.width)) / 2)
        let initialBrickOriginY = Constants.BrickSize.height * 2
        var nextBrickOrigin = CGPoint(x: initialBrickOriginX, y: initialBrickOriginY)
        
        for _ in 0..<brickRows {
            for _ in 0..<brickColumns {
                print("nextBrickOrigin = \(nextBrickOrigin)")
                
                let newBrick = UIView(frame: CGRect(origin: CGPoint.zero, size: Constants.BrickSize))
                newBrick.center = CGPoint(
                    x: nextBrickOrigin.x + (Constants.BrickSize.width / 2),
                    y: nextBrickOrigin.y + (Constants.BrickSize.height / 2))
                newBrick.backgroundColor = Constants.BrickColor
                newBrick.layer.borderColor = Constants.BrickBorderColor
                gameView.addSubview(newBrick)
                outBreakBehavior.addBrick(newBrick)
                newBricks.append(newBrick)
                nextBrickOrigin.x += Constants.BrickSize.width
            }
            nextBrickOrigin.x  = initialBrickOriginX
            nextBrickOrigin.y += Constants.BrickSize.height
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
        outBreakBehavior.addBall(newBall)
        ball = newBall
    }

}

