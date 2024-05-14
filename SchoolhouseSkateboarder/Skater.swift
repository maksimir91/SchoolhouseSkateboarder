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
    
    func setupPhysicsBody() {
        
        if let skaterTexture = texture {
            physicsBody = SKPhysicsBody(texture: skaterTexture, size: size)
            physicsBody?.isDynamic = true
            physicsBody?.density = 6.0
            // Разрешаем/запрещаем ротацию скейтбордистки тут
            physicsBody?.allowsRotation = false
            physicsBody?.angularDamping = 1.0
            physicsBody?.categoryBitMask = PhysicsCategory.skater
            physicsBody?.collisionBitMask = PhysicsCategory.brick
            physicsBody?.contactTestBitMask = PhysicsCategory.brick | PhysicsCategory.gem
        }
    }
}
