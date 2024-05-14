//
//  MenuLayer.swift
//  SchoolhouseSkateboarder
//
//  Created by Stanislav Shut on 14.05.2024.
//

import SpriteKit

class MenuLayer: SKSpriteNode {
// Отображает сообщение и иногда текущий счет
    func display(message: String, score: Int?) {
        // Создаем надпись сообщения, используя передаваемое сообщение
        let messageLabel: SKLabelNode = SKLabelNode(text: message)
        
        // Устанавливаем начальное положение надписа в левой стороне слоя меню
        let messageX = -frame.width
        let messageY = frame.height / 2.0
        messageLabel.position = CGPoint(x: messageX, y: messageY)
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.fontName = "Courier-Bold"
        messageLabel.fontSize = 48.0
        messageLabel.zPosition = 20
        addChild(messageLabel)
        
        // Анимируем движение надписи к центру экрана
        let finalX = frame.width / 2.0
        let messageAction = SKAction.moveTo(x: finalX, duration: 0.3)
        messageLabel.run(messageAction)
        
        // Если количество очков было передано методу, показываем надпись на экране
        if let scoreToDisplay = score {
            // Создаем текст с количеством очков из числа score
            let scoreString = String(format: "Очки:%04d", scoreToDisplay)
            let scoreLabel: SKLabelNode = SKLabelNode(text: scoreString)
            // Задаем начальное положение надписи справа от слоя меню
            let scoreLabelX = frame.width
            let scoreLabelY = messageLabel.position.y - messageLabel.frame.height
            scoreLabel.position = CGPoint(x: scoreLabelX, y: scoreLabelY)
            scoreLabel.horizontalAlignmentMode = .center
            scoreLabel.fontName = "Courier-Bold"
            scoreLabel.fontSize = 32.0
            scoreLabel.zPosition = 20
            addChild(scoreLabel)
            
            // Анимируем движение надписи в центр экрана
            let scoreAction = SKAction.moveTo(x: finalX, duration: 0.3)
            scoreLabel.run(scoreAction)
        }
    }
}
