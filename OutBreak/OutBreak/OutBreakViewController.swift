//
//  ViewController.swift
//  OutBreak
//
//  Created by Micah R Ledbetter on 2015-11-18.
//  Copyright © 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class OutBreakViewController: UIViewController, UICollisionBehaviorDelegate {
    
    // - MARK: Outlets
    
    @IBOutlet weak var gameView: UIView!
    
    // - MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        animator.addBehavior(outBreakBehavior)
        outBreakBehavior.obViewController = self

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
        case .Changed:
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
        if (item != ball) { return }

        if let brickId = identifier as? Int {
            removeBrickById(brickId)
        }
        else if let otherId = identifier as? String {
            if otherId == AppConstants.BottomSideBoundaryId {
                killBall()
            }
        }
    }
    
    // - MARK: Constants
    
    struct Constants {
        static let PaddleSize = CGSize(width: 80, height: 20)
        static let BrickSize  = CGSize(width: 40, height: 20)
        static let BallSize   = CGSize(width: 20, height: 20)
        static let PaddleColor = UIColor.grayColor()
        static let BrickColor  = UIColor.blueColor()
        static let BallColorNormal = UIColor.greenColor()
        static let BallColorDying  = UIColor.redColor()
        static let BrickBorderColor = UIColor.blackColor().CGColor
    }
    
    // - MARK: Game UI
    
    var ball: UIView?
    var paddle: UIView?
    //var bricks: [UIView]?
    var bricks: [Int: UIView]?
    
    var brickColumns: Int {
        return Int(gameView.bounds.width / Constants.BrickSize.width)
    }
    //var brickRows = 4
    var brickRows = 1
    
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
        var newBricks = [Int: UIView]()
        
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
                newBricks[brickId] = newBrick
                //newBricks.append(newBrick)
                nextBrickOrigin.x += Constants.BrickSize.width
                //++brickId
                brickId += 1
            }
            nextBrickOrigin.x  = initialBrickOriginX
            nextBrickOrigin.y += Constants.BrickSize.height
        }

        bricks = newBricks
    }
    
    func addBall() {
        if let oldBall = self.ball {
            outBreakBehavior.removeBall(oldBall)
            oldBall.removeFromSuperview()
        }
        let newBall = UIView(frame: CGRect(origin: CGPoint.zero, size: Constants.BallSize))
        newBall.center = CGPoint(
            x: gameView.center.x,
            y: gameView.center.y + (Constants.BallSize.height * 5))
        newBall.backgroundColor = Constants.BallColorNormal
        gameView.addSubview(newBall)
        outBreakBehavior.addBall(newBall)
        ball = newBall
    }
    
    func killBall() {
        guard let ball = ball else { return }
        outBreakBehavior.removeBall(ball)
        ball.backgroundColor = Constants.BallColorDying
        UIView.transitionWithView(ball, duration: 1.0, options: .TransitionCrossDissolve, animations: nil) {
            [unowned self] finished in
            self.addBall()
            self.gameView.setNeedsDisplay()
        }
    }
    
    func removeBrickById(brickId: Int) {
        guard let brick = bricks?[brickId] else { return }
        if bricks == nil { return }
        
        outBreakBehavior.removeBrickWithId(brickId)
        bricks!.removeValueForKey(brickId)
        UIView.transitionWithView(brick, duration: 0.25, options: .TransitionFlipFromLeft, animations: nil) {
            [unowned self] _ in
            brick.removeFromSuperview()
            self.gameView.setNeedsDisplay()
        }
        if bricks!.count == 0 {
            winGame()
        }
    }
    
    func winGame() {
        let alertController = UIAlertController(
            title: "YOU WIN!",
            message: "Your score was 0 because there is no score in this game, or in life. In the end, you and your score - like all of us - are nothing.",
            preferredStyle: .Alert)
        if let ball = ball { outBreakBehavior.removeBall(ball) }
        let acceptanceAction = UIAlertAction(title: "I accept this", style: .Default) {
            [unowned self] _ in
            self.addBall()
            self.addBricks()
        }
        alertController.addAction(acceptanceAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

