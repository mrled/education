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
        addChildBehavior(gravity)
    }
    
    // MARK: - Behaviors
    
    lazy var collider: UICollisionBehavior = {
        let lazyColi = UICollisionBehavior()
        lazyColi.translatesReferenceBoundsIntoBoundary = true
        return lazyColi
    }()
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let behave = UIDynamicItemBehavior()
        //behave.allowsRotation = true //? nah
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
    func addPaddle(paddle: UIView) {
        dynamicAnimator?.referenceView?.addSubview(paddle)
        collider.addItem(paddle)
    }
    func addBrick(brick: UIView) {
        dynamicAnimator?.referenceView?.addSubview(brick)
        collider.addItem(brick)
    }

}
