//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by Stanislav Shut on 12.05.2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    
//    private var label : SKLabelNode?
//    private var spinnyNode : SKShapeNode?
    
    // Массив, содержащий все текущие секции тротуара
    var bricks = [SKSpriteNode]()
    //Размер секций на тротуаре
    var brickSize = CGSize.zero
    // Настройка скорости движения направо для игры
    // Это значение может увеличиваться по мере продвижения пользователя в игре
    var scrollSpeed: CGFloat = 5.0
    // Константа для гравитации
    let gravitySpeed: CGFloat = 1.5
    // Время последнего вызова для метода обновления
    var lastUpdateTime: TimeInterval?
    
    // Создаем героя игры - скейтбордистку
    let skater = Skater(imageNamed: "skater")
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint.zero
        
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        // Настраиваем свойства скейтбордистки и добавляем ее в сцену
        resetSkater()
        addChild(skater)
        
        // Добавляем распознаватель нажатия, чтобы знать, когда пользователь нажимает на экран
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
    }
    
    func resetSkater() {
        // Задаем начальное положение скейтбордистки, zPosition и minimumY
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
    }
    
    func spawnBrick(atPosition position: CGPoint) -> SKSpriteNode {
        // Создаем спрайт секции и добавляем его к сцене
        let brick = SKSpriteNode(imageNamed: "sidewalk")
        brick.position = position
        brick.zPosition = 8
        addChild(brick)
        
        // Обновляем свойство brickSize реальным значением размера секции
        brickSize = brick.size
        
        // Добавляем новую секцию к массиву
        bricks.append(brick)
        
        // Возвращаем новую секцию вызывающему коду
        return brick
    }
    
    func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
        //Отслеживаем самое большое значение по оси Х для всех существующих секций
        var farthestRightBrickX: CGFloat = 0.0
        
        for brick in bricks {
            let newX = brick.position.x - currentScrollAmount
            // Если секция сместилась слишком далеко влево(за пределы экрана), удалите ее
            if newX < -brickSize.width {
                brick.removeFromParent()
                if let brickIndex = bricks.firstIndex(of: brick) {
                    bricks.remove(at: brickIndex)
                }
            } else {
                // Для секции, оставшейся на экране, обновлем положение
                brick.position = CGPoint(x: newX, y: brick.position.y)
                
                // Обновляем значение для крайней правой секции
                if brick.position.x > farthestRightBrickX {
                    farthestRightBrickX = brick.position.x
                }
            }
        }
        // Цикл while, обеспечивающий постоянное наполнение экрана секциями
        while farthestRightBrickX < frame.width {
            var brickX = farthestRightBrickX + brickSize.width + 1.0 // протестировать, как будет выглядеть без + 1.0
            let brickY = brickSize.height / 2.0
            
            // Время от времени оставляем разрывы, через которые герой должен перепрыгнуть
            let randomNumber = arc4random_uniform(99)
            if randomNumber < 5 {
                // 5% шанс на то, что возникнет разрыв
                let gap = 20.0 * scrollSpeed
                brickX += gap
            }
            // Добавляем новую секцию и обновляем положение самой правой
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
    }
    
    func updateSkater() {
        if !skater.isOnGround {
            // Устанавливаем новое значение скорости скейтбордистки с учетом влияния гравитации
            let velocityY = skater.velocity.y - gravitySpeed
            skater.velocity = CGPoint(x: skater.velocity.x, y: velocityY)
            // Устанавливаем новое положение скейтбордистки по оси y на основе ее скорости
            let newSkaterY: CGFloat = skater.position.y + skater.velocity.y
            skater.position = CGPoint(x: skater.position.x, y: newSkaterY)
            
            // Проверяем, приземлилась ли скейтбордистка
            if skater.position.y < skater.minimumY {
                skater.position.y = skater.minimumY
                skater.velocity = CGPoint.zero
                skater.isOnGround = true
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        var elapsedTime: TimeInterval = 0.0
        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp
        }
        lastUpdateTime = currentTime
        
        let expectedElapsedTime: TimeInterval = 1.0 / 60.0
        
        // Рассчитываем, насколько далеко должны сдвинуться объекты при данном обновлении
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
        updateBricks(withScrollAmount: currentScrollAmount)
        updateSkater()
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        // Скейтбордистка прыгает, если игрок нажимает на экран, пока она находится на земле
        if skater.isOnGround {
            // Задаем для скейтбордистки скорость по оси y, равную ее изначальной скорости прыжка
            skater.velocity = CGPoint(x: 0.0, y: skater.jumpSpeed)
            // Отмечаем, что скейтбордистка уже не находится на земле
            skater.isOnGround = false
        }
    }
}
