//
//  GameScene.swift
//  SchoolhouseSkateboarder
//
//  Created by Stanislav Shut on 12.05.2024.
//

import SpriteKit
import GameplayKit

// Эта структура содержит различные физические категории, и мы можем определить,
// какие типы объектов сталкиваются или контактируют друг с другом
struct PhysicsCategory {
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Enum для положения секции по y
    // Секции  на земле низкие, а секции на верхней платформе - высокие
    enum BrickLevel: CGFloat {
        case low = 0.0
        case high = 100.0
    }
    
    // Массив, содержащий все текущие секции тротуара
    var bricks = [SKSpriteNode]()
    // Массив, содержащий все активные алмазы
    var gems = [SKSpriteNode]()
    //Размер секций на тротуаре
    var brickSize = CGSize.zero
    // Текущий уровень определяет положение по оси y для новых секций
    var brickLevel = BrickLevel.low
    // Настройка скорости движения направо для игры
    // Это значение может увеличиваться по мере продвижения пользователя в игре
    var scrollSpeed: CGFloat = 5.0
    let startingScrollSpeed: CGFloat = 5.0
    // Константа для гравитации
    let gravitySpeed: CGFloat = 1.5
    // Свойства для отслеживания результата
    var score: Int = 0
    var highScore: Int = 0
    var lastScoreUpdateTime: TimeInterval = 0.0
    // Время последнего вызова для метода обновления
    var lastUpdateTime: TimeInterval?
    
    // Создаем героя игры - скейтбордистку
    let skater = Skater(imageNamed: "skater")
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.contactDelegate = self
        
        anchorPoint = CGPoint.zero
        
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        setupLabels()
        
        // Настраиваем свойства скейтбордистки и добавляем ее в сцену
        skater.setupPhysicsBody()
        addChild(skater)
        
        // Добавляем распознаватель нажатия, чтобы знать, когда пользователь нажимает на экран
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        startGame()
    }
    
    func resetSkater() {
        // Задаем начальное положение скейтбордистки, zPosition и minimumY
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
        
        skater.zRotation = 0.0
        skater.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        skater.physicsBody?.angularVelocity = 0.0
    }
    
    func setupLabels() {
        // Надпись со словами "очки" в верхнем левом углу
        let scoreTextLabel: SKLabelNode = SKLabelNode(text: "Очки")
        scoreTextLabel.position = CGPoint(x: 20.0, y: frame.size.height - 30.0)
        scoreTextLabel.horizontalAlignmentMode = .left
        scoreTextLabel.fontName = "Courier-Bold"
        scoreTextLabel.fontSize = 14.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        
        // Надпись с количеством очков игрока в текущей игре
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 20.0, y: frame.size.height - 60.0)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontSize = 18.0
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        // Надпись "лучший результат" в правом верхнем углу
        let highScoreTextLabel: SKLabelNode = SKLabelNode(text: "Лучший результат")
        highScoreTextLabel.position = CGPoint(x: frame.size.width - 20.0, y: frame.size.height - 30.0)
        highScoreTextLabel.horizontalAlignmentMode = .right
        highScoreTextLabel.fontName = "Courier-Bold"
        highScoreTextLabel.fontSize = 14.0
        highScoreTextLabel.zPosition = 20
        addChild(highScoreTextLabel)
        
        // Надпись с максимумом набранных игроком очков
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highScoreLabel.position = CGPoint(x: frame.size.width - 20.0, y: frame.size.height - 60.0)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 18.0
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
    }
    
    func updateScoreLabelText() {
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = String(format: "%04d", score)
        }
    }
    
    func updateHighScoreLabelText() {
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = String(format: "%04d", highScore)
        }
    }
    
    func startGame() {
        // Возвращаемся к начальным условиям при запуске новой игры
        resetSkater()
        
        score = 0
        scrollSpeed = startingScrollSpeed
        brickLevel = .low
        lastUpdateTime = nil
        
        for brick in bricks {
            brick.removeFromParent()
        }
        bricks.removeAll(keepingCapacity: true)
        
        for gem in gems {
            removeGem(gem)
        }
    }
    
    func gameOver() {
        // По завершении игры проверяем, добился ли игрок нового рекорда
        if score > highScore {
            highScore = score
            updateHighScoreLabelText()
        }
        
        startGame()
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
        
        // Настройка физического тела секции
        let center = brick.centerRect.origin
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size, center: center)
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.categoryBitMask = PhysicsCategory.brick
        brick.physicsBody?.collisionBitMask = 0
        
        // Возвращаем новую секцию вызывающему коду
        return brick
    }
    
    func spawnGem(atPosition position: CGPoint) {
        // Создаем спрайт для алмаза и добавляем его к сцене
        let gem = SKSpriteNode(imageNamed: "gem")
        gem.position = position
        gem.zPosition = 9
        addChild(gem)
        gem.physicsBody = SKPhysicsBody(rectangleOf: gem.size, center: gem.centerRect.origin)
        gem.physicsBody?.categoryBitMask = PhysicsCategory.gem
        gem.physicsBody?.affectedByGravity = false
        
        // Добавляем новый алмаз к массиву
        gems.append(gem)
    }
    
    func removeGem(_ gem: SKSpriteNode) {
        gem.removeFromParent()
        
        if let gemIndex = gems.firstIndex(of: gem) {
            gems.remove(at: gemIndex)
        }
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
            let brickY = (brickSize.height / 2.0) + brickLevel.rawValue
            
            // Время от времени оставляем разрывы, через которые герой должен перепрыгнуть
            let randomNumber = arc4random_uniform(99)
            if randomNumber < 2 && score > 10 {
                // 2% шанс на то, что возникнет разрыв между секциями после того, как игрок
                // набрал 10 очков
                let gap = 20.0 * scrollSpeed
                brickX += gap
                // На каждом разрыве добавляем алмаз
                let randomGemYAmount = CGFloat(arc4random_uniform(150))
                let newGemY = brickY + skater.size.height + randomGemYAmount
                let newGemX = brickX - gap / 2.0
                
                spawnGem(atPosition: CGPoint(x: newGemX, y: newGemY))
            } else if randomNumber < 4 && score > 20 {
                // В игре имеется 2% шанс на изменение уровня секции
                // 2% шанс на то, что уровень секции Y изменится после того, как игрок
                // набрал 20 очков
                if brickLevel == .high {
                    brickLevel = .low
                }
                else if brickLevel == .low {
                    brickLevel = .high
                }
            }
            // Добавляем новую секцию и обновляем положение самой правой
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
    }
    
    func updateGems(withScrollAmount currentScrollAmount: CGFloat) {
        for gem in gems {
            // Обновляем положение каждого алмаза
            let thisGemX = gem.position.x - currentScrollAmount
            gem.position = CGPoint(x: thisGemX, y: gem.position.y)
            
            // Удаляем любые алмазы, ушедшие с экрана
            if gem.position.x < 0.0 {
                removeGem(gem   )
            }
        }
    }
    
    func updateSkater() {
        // Определяем, находится ли скейтбордистка на земле
        if let velocityY = skater.physicsBody?.velocity.dy {
            
            if velocityY < -100.0 || velocityY > 100.0 {
                skater.isOnGround = false
            }
        }
        
        // Проверяем, должна ли игра закончиться
        let isOffScreen = skater.position.y < 0.0 || skater.position.x < 0.0
        
        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
        let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
        
        if isOffScreen || isTippedOver {
            gameOver()
        }
    }
    
    func updateScore(withCurrentTime currentTime: TimeInterval) {
        // Количество очков игрока увеличивается по мере игры
        // Счет обновляется каждую секунду
        let elapsedTime = currentTime - lastScoreUpdateTime
        
        if elapsedTime > 1.0 {
            // Увеличиваем кол-во очков
            score += Int(scrollSpeed)
            // Присвиваем свойству lastScoreUpdateTime значение текущего времени
            lastScoreUpdateTime = currentTime
            
            updateScoreLabelText()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Медленно увеличиваем значение scrollSpeed по мере развития игры
        scrollSpeed += 0.001
        
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
        updateGems(withScrollAmount: currentScrollAmount)
        updateScore(withCurrentTime: currentTime)
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        // Скейтбордистка прыгает, если игрок нажимает на экран, пока она находится на земле
        if skater.isOnGround {
            skater.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0))
        }
    }
    // MARK:- SKPhysicsContactDelegate Methods
    func didBegin(_ contact: SKPhysicsContact) {
        // Проверяем, есть ли контакт между скейтбордисткой и секцией
        if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.brick {
            skater.isOnGround = true
        } 
        else if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
            // Cкейтбордистка коснулась алмаза, поэтому мы его убираем
            if let gem = contact.bodyB.node as? SKSpriteNode {
                removeGem(gem)
                // Даем 50 очков игроку за собранный алмаз
                score += 50
                updateScoreLabelText()
            }
        }
    }
    
}
