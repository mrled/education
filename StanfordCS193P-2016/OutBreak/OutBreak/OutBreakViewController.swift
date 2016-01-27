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
    
    // - MARK: Public API
    
    func resetGame() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.gameShouldReset = false
        appDelegate.gameInProgress = false
        
        removePaddle()
        removeBricks()
        removeBall()

        self.paddle = nil
        self.bricks = nil
        self.ball = nil

        unpauseGame()
    }
    
    func unpauseGame() {
        addPaddle()
        addBricks()
        addBall()
    }
    
    // - MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        animator.addBehavior(outBreakBehavior)
        outBreakBehavior.obViewController = self
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.gameShouldReset {
            resetGame()
        }
        else {
            addPaddle()
            addBricks()
            addBall()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        animator.removeBehavior(outBreakBehavior)
    }

    // - MARK: Gestures
    
    @IBAction func pushBall(sender: UITapGestureRecognizer) {
        guard let ball = ball else { return }
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if !Defaults.objectForKey(DefaultsKey.BallIsTappable, withDefault: AppConstants.BallIsTappableDefault) {
            if appDelegate.gameInProgress {
                return
            }
            else {
                appDelegate.gameInProgress = true
            }
        }
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
                outBreakBehavior.movePaddle(paddle)
                gesture.setTranslation(CGPointZero, inView: gameView)
            }
        default: break
        }
    }
    
    // - MARK: Animation
    
    
    private lazy var animator: UIDynamicAnimator = {
        [unowned self] in
        return UIDynamicAnimator(referenceView: self.gameView)
    }()
    
    private let outBreakBehavior = OutBreakBehavior()
    
    // TODO: understand the difference between private and internal, and why do I have to use internal for this delegate method?
    internal func collisionBehavior(
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
    
    private struct Constants {
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
    
    private typealias Brick = (view: UIView, hitCount: Int)

    private var ball: UIView?
    private var paddle: UIView?
    private var bricks: [Int:Brick]?
    
    private var brickColumns: Int {
        return Int(gameView.bounds.width / Constants.BrickSize.width)
    }
    
    private func addPaddle() {
        removePaddle()
        let newPaddle = UIView(frame: CGRect(origin: CGPoint.zero, size: Constants.PaddleSize))
        newPaddle.center = CGPoint(
            x: gameView.center.x,
            y: gameView.bounds.height - (Constants.BrickSize.height * CGFloat(0.5) ))
        newPaddle.backgroundColor = Constants.PaddleColor
        gameView.addSubview(newPaddle)
        outBreakBehavior.addPaddle(newPaddle)
        paddle = newPaddle
    }
    private func removePaddle() {
        if let paddle = self.paddle {
            paddle.removeFromSuperview()
            outBreakBehavior.removePaddle(paddle)
            self.paddle = nil
        }
    }
    
    private func addBricks() {
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
    
    private func removeBricks() {
        if self.bricks != nil {
            for brickId in self.bricks!.keys { removeBrick(brickId) }
            self.bricks = nil
        }
    }
    
    private func addBall() {
        removeBall()
        let newBall = UIView(frame: CGRect(origin: CGPoint.zero, size: Constants.BallSize))
        newBall.center = CGPoint(
            x: gameView.center.x,
            y: gameView.center.y + (Constants.BallSize.height * 5))
        newBall.backgroundColor = Constants.BallColorNormal
        gameView.addSubview(newBall)
        outBreakBehavior.addBall(newBall)
        ball = newBall
    }
    private func removeBall() {
        if let oldBall = self.ball {
            outBreakBehavior.removeBall(oldBall)
            oldBall.removeFromSuperview()
            self.ball = nil
        }
    }
    
    // TODO: refactor this as removeBall(kill: Bool)
    private func killBall() {
        guard let ball = ball else { return }
        outBreakBehavior.removeBall(ball)
        ball.backgroundColor = Constants.BallColorDying
        UIView.transitionWithView(ball, duration: 1.0, options: .TransitionCrossDissolve, animations: nil) {
            [unowned self] finished in
            self.addBall()
            self.gameView.setNeedsDisplay()
        }
    }
    
    // TODO: refactor hitBrick and removeBrick into one function
    //       determine if it was hit by a ball or not and if so, do animation and check for win conditions; if not, just remove
    private func hitBrick(brickId: Int) {
        print("Hit brick with id \(brickId)")
        bricks![brickId]!.hitCount += 1
        
        let brickView = bricks![brickId]!.view
        UIView.transitionWithView(brickView, duration: 0.25, options: .TransitionFlipFromLeft, animations: nil) {
            [unowned self] animationFinished in
            if self.bricks == nil { return }
            
            let brickMaxHitCount = Defaults.objectForKey(DefaultsKey.BrickMaxHitCount, withDefault: AppConstants.BrickMaxHitCountDefault)
            if self.bricks![brickId]?.hitCount >= brickMaxHitCount {
                self.removeBrick(brickId)
            }
            if self.bricks!.count == 0 {
                self.winGame()
            }
        }
    }
    
    private func removeBrick(brickId: Int) {
        print("Removing brick with id \(brickId)")
        guard let brick = bricks?[brickId] else { return }
        
        outBreakBehavior.removeBrickWithId(brickId)
        bricks!.removeValueForKey(brickId)
        brick.view.removeFromSuperview()
        //self.gameView.setNeedsDisplay()

    }
    
    private func winGame() {
        removeBall()
        removeBricks()
        removePaddle()

        let alertController = UIAlertController(
            title: "YOU WIN!",
            message: "Your score was 0 because there is no score in this game, or in life. In the end, you and your score - like all of us - are nothing.",
            preferredStyle: .Alert)
        let acceptanceAction = UIAlertAction(title: "I accept this", style: .Default) {
            [unowned self] _ in
            self.addBall()
            self.addBricks()
        }
        alertController.addAction(acceptanceAction)
        self.presentViewController(alertController, animated: true) {
            [unowned self] in
            self.resetGame()
        }
    }

}

