//
//  OutBreakBehavior.swift
//  OutBreak
//
//  Created by Micah R Ledbetter on 2015-11-19.
//  Copyright © 2015 Micah R Ledbetter. All rights reserved.
//

import UIKit

class OutBreakBehavior: UIDynamicBehavior {
    
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
    }
    
    // MARK: - Member variables
    var obViewController: OutBreakViewController? {
        didSet {
            guard let obViewController = obViewController as? UICollisionBehaviorDelegate else { return }
            collider.collisionDelegate = obViewController
            erectWallsInGameView()
        }
    }
    
    // MARK: - Behaviors
    
    lazy var collider: UICollisionBehavior = {
        let lazyColi = UICollisionBehavior()
        return lazyColi
    }()
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let behave = UIDynamicItemBehavior()
        behave.allowsRotation = false
        behave.elasticity = 1
        behave.friction = 0
        behave.resistance = 0
        return behave
    }()
    
    let gravity = UIGravityBehavior()
    
    // MARK: - Adding objects
    
    func addBall(ball: UIView) {
        //dynamicAnimator?.referenceView?.addSubview(ball)
        gravity.addItem(ball)
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    func removeBall(ball: UIView) {
        gravity.removeItem(ball)
        collider.removeItem(ball)
        ballBehavior.removeItem(ball)
    }
    func addOrMovePaddle(paddle: UIView) {
        collider.removeBoundaryWithIdentifier(AppConstants.PaddleBoundaryId)
        collider.addBoundaryWithIdentifier(AppConstants.PaddleBoundaryId, forPath: UIBezierPath(ovalInRect: paddle.frame))
    }
    func addBrick(brick: UIView, withId brickId: Int) {
        removeBrickWithId(brickId)
        collider.addBoundaryWithIdentifier(brickId, forPath: UIBezierPath(rect: brick.frame))
    }
    func removeBrickWithId(brickId: Int) {
        collider.removeBoundaryWithIdentifier(brickId)
    }
    func pushRandomly(object: UIView) {
        let randomPush = UIPushBehavior(items: [], mode: .Instantaneous)

        randomPush.magnitude = CGFloat.random(min: 0.05, max: 0.25)
        randomPush.angle = CGFloat.random(min: 0, max: 360)
        randomPush.active = true
        randomPush.action = {
            [unowned self] in
            self.removeChildBehavior(randomPush)
        }
        randomPush.addItem(object)
        addChildBehavior(randomPush)
    }
    func erectWallsInGameView() {
        guard let gameView = obViewController?.gameView else { return }
        
        let upperLeft = CGPoint(x:0, y:0)
        let lowerLeft = CGPoint(x:0, y:gameView.bounds.size.height)
        let upperRight = CGPoint(x:gameView.bounds.size.width, y:0)
        let lowerRight = CGPoint(x:gameView.bounds.size.width, y:gameView.bounds.size.height)
        
        collider.addBoundaryWithIdentifier(AppConstants.LeftSideBoundaryId,   fromPoint: upperLeft,  toPoint: lowerLeft)
        collider.addBoundaryWithIdentifier(AppConstants.RightSideBoundaryId,  fromPoint: upperRight, toPoint: lowerRight)
        collider.addBoundaryWithIdentifier(AppConstants.TopSideBoundaryId,    fromPoint: upperLeft,  toPoint: upperRight)
        collider.addBoundaryWithIdentifier(AppConstants.BottomSideBoundaryId, fromPoint: lowerLeft,  toPoint: lowerRight)
    }
}

private extension CGFloat {
    private static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    private static func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
}
