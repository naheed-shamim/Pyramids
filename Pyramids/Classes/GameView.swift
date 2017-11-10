//
//  GameView.swift
//  Pyramids
//
//  Created by Naheed Shamim on 27/10/17.
//  Copyright © 2017 Naheed Shamim. All rights reserved.
//

import UIKit
import SceneKit

protocol GameScoreDelegate : class
{
    func updateScore(score:Int)
    func updateLives(life:Int)
}

let kFriendNode = "friend"
let kEnemyNode = "enemy"

class GameView: SCNView,SCNSceneRendererDelegate
{
    //MARK: - Variables
    //MARK: -SceneKit variables
    weak var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    
    //MARK: -Game variables
    var startTime = TimeInterval()
    var targetCreationTime:TimeInterval = 0
    var levelPoints = 0
    var score = 0
    var isGamePaused : Bool = false
    var isGameOver : Bool = false
    var lives = 3
    var level = 0
    
    weak var scoreDelegate : GameScoreDelegate?
    
    
    //MARK: - Init/Deinit Methods
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupGame()
    }
    
    init()
    {
        super.init(frame: CGRect(x: 0, y: hudHieght, width: screenWidth, height: screenHeight),
                   options: nil)
        setupGame()
    }
    
    deinit
    {
        gameView = nil
        gameScene = nil
        cameraNode = nil
    }
    
    
    //MARK: - Private Methods
    func setupGame()
    {
        initView()
        initScene()
        initCamera()
    }
    
    func initView()
    {
        gameView = self
        gameView.backgroundColor = UIColor.black
//        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        
        gameView.delegate = self
    }
    
    func initScene ()
    {
        gameScene = SCNScene()
        gameView.scene = gameScene
        
        gameView.isPlaying = true
    }
    
    func initCamera()
    {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y:5, z: 10)
        
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
     //MARK: - Game Specific Functions
    func setLevel(level:Int)
    {
        levelPoints = level
    }
    
    func iGamePaused() -> Bool
    {
        return (gameView.scene?.isPaused)!
    }
    
    func pauseGame()
    {
        gameView.scene?.isPaused = !(gameView.scene?.isPaused)!
        isGamePaused = (gameView.scene?.isPaused)!
        gameView.isUserInteractionEnabled = !isGamePaused
    }
    
    func stopGame()
    {
        gameView.stop(self)
    }
    
    func gameOver()
    {
        self.isGameOver = true
        self.scoreDelegate = nil
        updateHighScore()
        stopGame()
        
        DispatchQueue.main.async
            {
                GameOverView.sharedInstance.showScore(score: self.score, overView: self)
        }
    }
    
    func updateHighScore()
    {
        if let maxScore = Utility.getHighScore()
        {
            if self.score > maxScore
            {
                Utility.saveHighScore(score: self.score)
            }
        }
    }
    
    func isLifePresent() -> Bool
    {
        if self.lives < 1{
            return false
        }
        
        return true
    }
    
    func increaseLevel()
    {
        //With New level
        //Life is also increased, levelPoints also increased by 1
        self.level = self.level + 1
        self.levelPoints = self.levelPoints + 1
        
        self.lives = self.lives + 1
        self.scoreDelegate?.updateLives(life: self.lives)
        
        //Max Level is 8
        if self.level > 8 {
            self.level = 8
        }
        
        //Max Lives are 8
        self.lives = self.lives > 8 ? 8 : self.lives
    }
    
    //MARK: - Node Specific Functions
    func getGeometry() -> Array<SCNGeometry>
    {
        var geometryArray : Array<SCNGeometry> = []
        
        geometryArray.append(SCNPyramid(width: 1, height: 1, length: 1))
        geometryArray.append(SCNCone(topRadius: 0, bottomRadius: 0.5, height: 1))
        geometryArray.append(SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
        
        return geometryArray
    }
    
    func colorsArray() -> Array<UIColor>
    {
        var colors : Array<UIColor> = []
        
        colors.append(UIColor.yellow)
        colors.append(UIColor.red)
        colors.append(UIColor.cyan)
        colors.append(UIColor.green)
        
        return colors
    }
    
    func createTarget()
    {
        let randomIndex:Int = Int(arc4random_uniform(UInt32(getGeometry().count)))
        let randomGeometry = getGeometry()[randomIndex]
        
        let colorIndex = Int(arc4random_uniform(UInt32(colorsArray().count)))
        let randomColor = colorsArray()[colorIndex]
        
        randomGeometry.materials.first?.diffuse.contents = randomColor
        
        let geometryNode = SCNNode(geometry: randomGeometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        if randomColor == UIColor.green //&& randomGeometry.isKind(of: SCNPyramid())
        {
            geometryNode.name = kFriendNode
        }
        else
        {
            geometryNode.name = kEnemyNode
        }
        
        gameScene.rootNode.addChildNode(geometryNode)
        setForceOnNode(node: geometryNode)
    }
    
    func setForceOnNode(node:SCNNode)
    {
        var yDirection : Float = 0
        var position : Float = 0
        var zCameraPos : Float = 0
        var yCameraPos : Float = 0
        
        
        switch self.level
        {
            case 1 :
                        zCameraPos = 10
                        yCameraPos = 5
                        yDirection = 12
                        position = 0.05
                    break
            case 2 :    zCameraPos = 11
                        yCameraPos = 5
                        yDirection = 13
                        position = 0.10
                    break
            case 3 :    zCameraPos = 13
                        yCameraPos = 5
                        yDirection = 14
                        position = 0.15
                    break
            case 4 :    zCameraPos = 14
                        yCameraPos = 6
                        yDirection = 16
                        position = 0.20
                    break
            case 5 :    zCameraPos = 15
                        yCameraPos = 6
                        yDirection = 17
                        position = 0.25
                    break
            case 6 :    zCameraPos = 15
                        yCameraPos = 7
                        yDirection = 18
                        position = 0.25
                    break
            case 7 :    zCameraPos = 15
                        yCameraPos = 7
                        yDirection = 19
                        position = 0.25
                    break
            case 8 :    zCameraPos = 16
                        yCameraPos = 8
                        yDirection = 20
                        position = 0.25
                    break
            default :   zCameraPos = 15
                        yCameraPos = 11
                        yDirection = 25
                        position = 0.15
        }
        
        cameraNode.position = SCNVector3(x: 0, y: yCameraPos, z: zCameraPos)
        
        let randomDirection:Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let force = SCNVector3(x: randomDirection, y: yDirection, z: 0)
        
        node.physicsBody?.applyForce(force, at: SCNVector3(x: position, y: position, z: position), asImpulse: true)
    }
    
    func setTargetCreationTime(time:TimeInterval)
    {
        var timeInterval : Double = 0
        
        switch self.level
        {
            case 1 : timeInterval = 0.8
                break
            case 2 : timeInterval = 0.8
                break
            case 3 : timeInterval = 0.7
                break
            case 4 : timeInterval = 0.7
                break
            case 5 : timeInterval = 0.5
                break
            case 6 : timeInterval = 0.5
                break
            case 7 : timeInterval = 0.5
                break
            case 8 : timeInterval = 0.4
                break
            default : timeInterval = 0.8
        }
        
        self.targetCreationTime = time + timeInterval
    }
    
    // This function clears all the nodes that goes out of view and updates the Score and Lives
    func cleanUp ()
    {
        for node in gameScene.rootNode.childNodes
        {
            if node.presentation.position.y < 0
            {
                if isLifePresent()
                {
                    if node.name == kFriendNode
                    {
                        self.lives = self.lives - 1
                        self.score = (score - levelPoints) < 0 ? 0 : (score - levelPoints)
                        print("\(score)")
                        
                        if self.scoreDelegate != nil
                        {
                            self.scoreDelegate?.updateScore(score: self.score)
                            self.scoreDelegate?.updateLives(life: self.lives)
                        }
                    }
                    node.removeFromParentNode()
                }
                else
                {
                    if !isGameOver
                    {
                        gameOver()
                    }
                }
            }
        }
    }
    
    
    //MARK: - SCNSceneRenderer Delegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        print("\(time)")
     
        if(time - self.startTime > 15 )
        {
            self.startTime = time
            increaseLevel()
        }
        
        if !isGamePaused
        {
            if isLifePresent()
            {
                if time > self.targetCreationTime
                {
                    createTarget()
                    setTargetCreationTime(time: time)
                }
            }
            else
            {
                if !isGameOver
                {
                    gameOver()
                }
            }
            cleanUp()
        }
    }
    
    //MARK: - TouchesBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location, options: nil)
        
        if isLifePresent()
        {
            if let hitObject = hitList.first
            {
                let node = hitObject.node
                
                //if the node touched is a friend, increase Score
                //else decrease the Life
                if node.name == kFriendNode
                {
                    self.score = self.score + levelPoints
                    node.removeFromParentNode()
                    self.gameView.backgroundColor = UIColor.black
                }
                else
                {
                    self.score = (score - levelPoints) < 0 ? 0 : (score - levelPoints)
                    self.lives = self.lives - 1
                    
                    self.scoreDelegate?.updateLives(life: self.lives)
                    
                    node.removeFromParentNode()
                    self.gameView.backgroundColor = UIColor.red
                }
            
                print("\(score)")
                
                if scoreDelegate != nil{
                    self.scoreDelegate?.updateScore(score: self.score)
                }
            }
        }
    }
    
    
    
}
