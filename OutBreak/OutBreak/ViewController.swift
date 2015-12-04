//
//  ViewController.swift
//  OutBreak
//
//  Created by Micah R Ledbetter on 2015-11-18.
//  Copyright © 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {
    
    // - MARK: Outlets
    
    @IBOutlet weak var gameView: UIView!
    
    // - MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        animator.addBehavior(outBreakBehavior)
        outBreakBehavior.viewController = self

        if paddle == nil { addPaddle() }
        if bricks == nil { addBricks() }
        if ball == nil { addBall() }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        animator.removeBehavior(outBreakBehavior)
    }

    // - MARK: Gestures
    
    @IBAction func pushBall(sender: UITapGestureRecognizer) {
        guard let ball = ball else { return } 
        outBreakBehavior.pushRandomly(ball)
    }
    @IBAction func movePaddle(gesture: UIPanGestureRecognizer) {
        guard let paddle = paddle else { return }
        
        switch gesture.state {
        case .Ended: fallthrough
        case.Changed:
            let xChange = gesture.translationInView(gameView).x
            if xChange != 0 {
                paddle.center.x += xChange
                outBreakBehavior.addOrMovePaddle(paddle)
                gesture.setTranslation(CGPointZero, inView: gameView)
            }
        default: break
        }
    }
    
    // - MARK: Animation
    
    
    lazy var animator: UIDynamicAnimator = {
        [unowned self] in
        return UIDynamicAnimator(referenceView: self.gameView)
    }()
    
    let outBreakBehavior = OutBreakBehavior()
    
    func collisionBehavior(
        behavior: UICollisionBehavior,
        beganContactForItem item: UIDynamicItem,
        withBoundaryIdentifier identifier: NSCopying?,
        atPoint p: CGPoint)
    {
        guard let ball = ball else { return }
        guard let item = item as? UIView else { return }
        guard let identifier = identifier as? Int else { return }
        guard let bricks = bricks else { return }
        if (item != ball) { return }

        let brick = bricks[identifier]
        outBreakBehavior.removeBrickWithId(identifier)
        UIView.transitionWithView(brick, duration: 0.25, options: .TransitionFlipFromLeft, animations: nil) {
            [unowned self] finished in
            brick.removeFromSuperview()
            self.gameView.setNeedsDisplay()
        }
    }

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
        outBreakBehavior.addOrMovePaddle(newPaddle)
        paddle = newPaddle
    }
    
    func addBricks() {
        var newBricks = [UIView]()
        
        let initialBrickOriginX = ((gameView.bounds.width - (CGFloat(brickColumns) * Constants.BrickSize.width)) / 2)
        let initialBrickOriginY = Constants.BrickSize.height * 2
        var nextBrickOrigin = CGPoint(x: initialBrickOriginX, y: initialBrickOriginY)
        var brickId: Int = 0
        
        for _ in 0..<brickRows {
            for _ in 0..<brickColumns {
                let newBrick = UIView(frame: CGRect(origin: CGPoint.zero, size: Constants.BrickSize))
                newBrick.center = CGPoint(
                    x: nextBrickOrigin.x + (Constants.BrickSize.width / 2),
                    y: nextBrickOrigin.y + (Constants.BrickSize.height / 2))
                newBrick.backgroundColor = Constants.BrickColor
                newBrick.layer.borderColor = Constants.BrickBorderColor
                gameView.addSubview(newBrick)
                outBreakBehavior.addBrick(newBrick, withId: brickId)
                newBricks.append(newBrick)
                nextBrickOrigin.x += Constants.BrickSize.width
                ++brickId
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

