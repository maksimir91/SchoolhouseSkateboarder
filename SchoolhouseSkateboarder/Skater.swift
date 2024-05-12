//
//  Skater.swift
//  SchoolhouseSkateboarder
//
//  Created by Stanislav Shut on 12.05.2024.
//

import SpriteKit

class Skater: SKSpriteNode {
    var velocity = CGPoint.zero
    var minimumY: CGFloat = 0.0
    var jumpSpeed: CGFloat = 20.0
    var isOnGround = true
}
