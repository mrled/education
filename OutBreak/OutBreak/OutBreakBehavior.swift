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
    
    struct Constants {
        static let PaddleBoundaryId = "Paddle"
    }
    
    // MARK: - Member variables
    var viewController: UIViewController? {
        didSet {
            guard let viewController = viewController as? UICollisionBehaviorDelegate else { return }
            collider.collisionDelegate = viewController
        }
    }
    
    // MARK: - Behaviors
    
    lazy var collider: UICollisionBehavior = {
        let lazyColi = UICollisionBehavior()
        lazyColi.translatesReferenceBoundsIntoBoundary = true
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
        dynamicAnimator?.referenceView?.addSubview(ball)
        gravity.addItem(ball)
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    func addOrMovePaddle(paddle: UIView) {
        collider.removeBoundaryWithIdentifier(Constants.PaddleBoundaryId)
        collider.addBoundaryWithIdentifier(Constants.PaddleBoundaryId, forPath: UIBezierPath(ovalInRect: paddle.frame))
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
}

private extension CGFloat {
    private static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    private static func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
}
