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

        addPaddle()
        addBricks()
        addBall()
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
            hitBrick(brickId)
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
    
    typealias Brick = (view: UIView, hitCount: Int)

    var ball: UIView?
    var paddle: UIView?
    var bricks: [Int:Brick]?
    
    var brickColumns: Int {
        return Int(gameView.bounds.width / Constants.BrickSize.width)
    }
    
    func addPaddle() {
        if let paddle = self.paddle {
            // Paddle already exists but I have to re-add boundaries to OutBreakBehavior
            outBreakBehavior.addOrMovePaddle(paddle)
        }
        else {
            let newPaddle = UIView(frame: CGRect(origin: CGPoint.zero, size: Constants.PaddleSize))
            newPaddle.center = CGPoint(
                x: gameView.center.x,
                y: gameView.bounds.height - (Constants.BrickSize.height * CGFloat(0.5) ))
            newPaddle.backgroundColor = Constants.PaddleColor
            gameView.addSubview(newPaddle)
            outBreakBehavior.addOrMovePaddle(newPaddle)
            paddle = newPaddle
        }
    }
    
    func addBricks() {
        if let bricks = self.bricks {
            // These bricks were already initialized once, but we need to re-add the boundaries to our OutBreakBehavior
            for brickId in bricks.keys {
                let brick = bricks[brickId]!
                outBreakBehavior.addBrick(brick.view, withId: brickId)
            }
        }
        else {
            // We have not initialized our bricks - start a new game
            var newBricks = [Int: Brick]()
            
            let initialBrickOriginX = ((gameView.bounds.width - (CGFloat(brickColumns) * Constants.BrickSize.width)) / 2)
            let initialBrickOriginY = Constants.BrickSize.height * 2
            var nextBrickOrigin = CGPoint(x: initialBrickOriginX, y: initialBrickOriginY)
            var brickId: Int = 0
            
            for _ in 0..<Defaults.objectForKey(DefaultsKey.BrickRowCount, withDefault: AppConstants.BrickRowCountDefault) {
                for _ in 0..<brickColumns {
                    let newBrickView = UIView(frame: CGRect(origin: CGPoint.zero, size: Constants.BrickSize))
                    newBrickView.center = CGPoint(
                        x: nextBrickOrigin.x + (Constants.BrickSize.width / 2),
                        y: nextBrickOrigin.y + (Constants.BrickSize.height / 2))
                    newBrickView.backgroundColor = Constants.BrickColor
                    newBrickView.layer.borderColor = Constants.BrickBorderColor
                    gameView.addSubview(newBrickView)
                    outBreakBehavior.addBrick(newBrickView, withId: brickId)
                    newBricks[brickId] = (view: newBrickView, hitCount: 0)
                    nextBrickOrigin.x += Constants.BrickSize.width
                    brickId += 1
                }
                nextBrickOrigin.x  = initialBrickOriginX
                nextBrickOrigin.y += Constants.BrickSize.height
            }
            
            bricks = newBricks
        }
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
    
    func hitBrick(brickId: Int) {
        bricks?[brickId]?.hitCount += 1
        if let brickView = bricks?[brickId]?.view {
            UIView.transitionWithView(brickView, duration: 0.25, options: .TransitionFlipFromLeft, animations: nil, completion:  nil)
        }
        if bricks?[brickId]?.hitCount == Defaults.objectForKey(DefaultsKey.BrickMaxHitCount, withDefault: AppConstants.BrickMaxHitCountDefault) {
            removeBrick(brickId)
        }
    }
    
    func removeBrick(brickId: Int) {
        guard let brick = bricks?[brickId] else { return }
        if bricks == nil { return }
        
        outBreakBehavior.removeBrickWithId(brickId)
        bricks!.removeValueForKey(brickId)
        UIView.transitionWithView(brick.view, duration: 0.25, options: .TransitionFlipFromLeft, animations: nil) {
            [unowned self] _ in
            brick.view.removeFromSuperview()
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

