//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by Stanislav Shut on 12.05.2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint.zero
        
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
