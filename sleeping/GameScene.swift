//
//  GameScene.swift
//  sleeping
//
//  Created by Yuta on 2016/11/03.
//  Copyright © 2016年 Yuta. All rights reserved.
//

import UIKit
import SpriteKit

protocol GameSceneDelegate {
    func gameAlert(message : String)
    func dataSend(Score: Int, Clear: Int)
}

class GameScene: SKScene{
    var gameSceneDelegate: GameSceneDelegate!
    
    
/* ----- variable management zone ----- */
    // important
    let userDefaults:UserDefaults = UserDefaults.standard
    var remainingTime = 10              // イベント時間 通常60s
    
    var score = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var TitleBackLabel:SKLabelNode!
    var timeLabel:SKLabelNode!
    
    // Item SpriteNode
    var landscapeSprite:SKSpriteNode!   // 風景
    var windowSprite:SKSpriteNode!      // 窓枠
    var manSprite:SKSpriteNode!         // 寝てる人
    var denkiSprite:SKSpriteNode!       // 電気
    var switchSprite:SKSpriteNode!      // 電気のスイッチ
    var mezamasiSprite:SKSpriteNode!    // 目覚まし
    var gokiSprite:SKSpriteNode!        // goki
    var lightStandSprite:SKSpriteNode!  // 電気スタンド
    var lightZoneSprite:SKSpriteNode!   // 電気スタンドで明るい部分(白い丸の絵)
    var ballSprite:SKSpriteNode!        // ボール
    
    // check
    var denkiCheck = false              // 電気がついてたら true
    var gameOver = false                // gameOver なら true
    var gameClear = false               // クリアしたら true
    
    // timer
    var timer = Timer()                 // ゲームの残り時間
    var eventTimer = Timer()            // eventManagerへ毎秒アクセス
    var denkiTimer = Timer()            // 電気が入ってから何秒経ったか計測
    var mezamasiTimer = Timer()         // 目覚ましが鳴っている時間
    var lightStandTimer = Timer()       // ライトスタンドがついている時間
    var ballTimer = Timer()             // ボール飛来
    var timerBehavior = false           // 未使用
    
    let magnification:CGFloat = 0.5     // オブジェクトの倍率管理
    var denkiSeconds = 0                // 電気つけて経った時間
    var mezamasiSeconds = 0             // 目覚まし鳴ってからの時間
    var standSecond = 0                 // 電気スタンドがついている時間
    var ballSecond = 0                  // ボール飛来時間管理
    
/* ----- variable management zone fin ----- */
    
    
    override func didMove(to view: SKView) {
        /* memo
         *
         * 背景色は各window関数の中
         *
         */
        
        
        // setup
        let difficult = decideDifficulty()
        physicsWorld.gravity = CGVector(dx: Double(5 - difficult)*0.07, dy: Double(5 - difficult)*(-0.05))
        
        // setup function
        setupScoreLabel()
        setupTitleBackLabel()
        setupDifficulty()
        setupNightWindow()
        setupSleepingMan()
        
        // Initial set
        time() //time内でeventManagementを起動
        denkiOff()
        
        //その他（実装中）
        
        
        // 実装済みイベント
        //callMezamasi()
        //goki()
        //lightStand()
        //broken()
        
        // 実装予定イベント
        // yuurei
        
    }
    


    func eventManagement(){
        let difficult = difficulty()
        let nowData = (difficult, remainingTime)
        
        switch nowData {
        case (_,55):
            break
        case (_,0):
            morning()
            wakeupMan()
            eventTimer.invalidate()
        default:
            //print("occured eventManagement function Switch case default")
            break
        }
        
        // その他イベント
        print("nowData:\(nowData)")
        if score > userDefaults.integer(forKey: "BEST") {
            userDefaults.set(score, forKey: "BEST")
            userDefaults.synchronize()
        }
        scoreLabelNode.text = "Score : \(score)"
        bestScoreLabelNode.text = "Best : \(userDefaults.integer(forKey: "BEST"))"
        
    }
    
    // タッチイベント処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view?.isMultipleTouchEnabled = true
        for touch in touches {
            let difficult = difficulty()
            let location = touch.location(in: self)
            let touchNodes = self.nodes(at: location)
            for tNode in touchNodes {
                // 電気のスイッチ
                if tNode == switchSprite {
                    switchDenki()
                    denkiSeconds = 0
                }
                // ゴキブリ
                if gokiSprite != nil && tNode == gokiSprite {
                    gokiSprite.removeFromParent()
                    score += difficult * 100
                }
                // 目覚まし時計
                if mezamasiSprite != nil && tNode == mezamasiSprite {
                    mezamasiSprite.removeFromParent()
                    mezamasiTimer.invalidate()
                    mezamasiSeconds = 0
                    score += 100
                }
                // 電気スタンド
                if lightStandSprite != nil && tNode == lightStandSprite {
                    lightStandSprite.removeFromParent()
                    lightZoneSprite.removeFromParent()
                    lightStandTimer.invalidate()
                    standSecond = 0
                    score += 100
                }
                // broken
                if ballSprite != nil && tNode == ballSprite {
                    ballSprite.removeFromParent()
                    ballTimer.invalidate()
                    ballSecond = 0
                    score += 200 + difficult * 10
                }
                scoreLabelNode.text = "Score : \(score)"
            }
        }
    }
    

    
    func gameOverAlert(type: Int){
        timer.invalidate()
        eventTimer.invalidate()

        var message:String
        switch type {
        case 1: message = "眩しくて起きた"
        case 2: message = "目覚ましで起きた"
        case 3: message = "ガラスが割れた音で起きた"
        default: message = "想定されていないエラー番号です"
        }
        gameOver = true
        gameSceneDelegate.gameAlert(message: message)
        gameSceneDelegate.dataSend(Score: score, Clear: gameFinish())
    }
    

    
    
/* ----- Event Function Zone ----- */
    func morning(){
        backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)

        landscapeSprite.removeFromParent()
        //朝の風景
        landscapeSprite = SKSpriteNode(imageNamed: "asa")
        landscapeSprite.position = CGPoint(x: frame.size.width/2 - 70, y: frame.size.height/2 + 100)
        landscapeSprite.zPosition = 97
        landscapeSprite.setScale(magnification)
        addChild(landscapeSprite)

    }
    
    func wakeupMan(){
        manSprite.removeFromParent()
        manSprite = SKSpriteNode(imageNamed: "bed_boy_wake")
        manSprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2 - 90 )
        manSprite.setScale(magnification)
        manSprite.zPosition = 100
        addChild(manSprite)
    }
    
    func denkiOn(){
        denkiSprite = SKSpriteNode(imageNamed: "light_on")
        denkiSprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height - 70)
        denkiSprite.zPosition = -10
        denkiSprite.setScale(1.5)
        addChild(denkiSprite)
        
        switchSprite = SKSpriteNode(imageNamed: "switch_on")
        switchSprite.position = CGPoint(x: 50, y: frame.size.height/2 - 60)
        switchSprite.zPosition = 100
        switchSprite.setScale(0.3)
        addChild(switchSprite)
    }
    
    func denkiOff(){
        denkiSprite = SKSpriteNode(imageNamed: "light_off")
        denkiSprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height - 70)
        denkiSprite.zPosition = -10
        denkiSprite.setScale(1.5)
        addChild(denkiSprite)
        
        switchSprite = SKSpriteNode(imageNamed: "switch_off")
        switchSprite.position = CGPoint(x: 50, y: frame.size.height/2 - 60)
        switchSprite.zPosition = 100
        switchSprite.setScale(0.3)
        addChild(switchSprite)
    }
    
    func switchDenki(){
        switchSprite.removeFromParent()
        denkiSprite.removeFromParent()
        if denkiCheck == false {
            denkiOn()
            backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)
            denkiTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(denkiCount), userInfo: nil, repeats: true)
            denkiCheck = true
        }else{
            denkiOff()
            denkiTimer.invalidate()
            backgroundColor = UIColor(colorLiteralRed: 0.7, green: 0.7, blue: 0.7, alpha: 1)
            denkiCheck = false
        }
    }
    
    func denkiCount(){
        denkiSeconds += 1
        print("denkiSeconds = \(denkiSeconds)")
        
        let difficult = difficulty()
        if (difficult == 1 && denkiSeconds == 5) ||
           (difficult == 2 && denkiSeconds == 3) ||
           (difficult == 3 && denkiSeconds == 2) {
            denkiTimer.invalidate()
            gameOver = true
            gameOverAlert(type: 1)
        }
    }
    
    func callMezamasi(){
        let mezamasiTextureA = SKTexture(imageNamed: "mezamasi_1")
        let mezamasiTextureB = SKTexture(imageNamed: "mezamasi_2")
        let texuresAnimation = SKAction.animate(with: [mezamasiTextureA, mezamasiTextureB],timePerFrame: 0.1)
        let mezamasi = SKAction.repeatForever(texuresAnimation)
        mezamasiSprite = SKSpriteNode(texture: mezamasiTextureA)
        mezamasiSprite.position = CGPoint(x: frame.size.width - 70, y: frame.size.height/2 - 130)
        mezamasiSprite.zPosition = 97
        mezamasiSprite.setScale(0.3)
        mezamasiSprite.run(mezamasi)
        addChild(mezamasiSprite)
        
        mezamasiTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(mezamasiCount), userInfo: nil, repeats: true)
    }
    
    func mezamasiCount(){
        mezamasiSeconds += 1
        print("mezamasiSeconds = \(mezamasiSeconds)")
        
        let difficult = difficulty()
        if (difficult == 1 && mezamasiSeconds == 5) ||
            (difficult == 2 && mezamasiSeconds == 3) ||
            (difficult == 3 && mezamasiSeconds == 2) {
            mezamasiTimer.invalidate()
            gameOverAlert(type: 2)
        }
    }
    
    func goki(){
        let x = decideDifficulty()
        gokiSprite = SKSpriteNode(imageNamed: "goki")
        gokiSprite.position = CGPoint(x: -100, y:  100)
        gokiSprite.zPosition = 100
        gokiSprite.setScale(CGFloat(Double(x) * 0.1 + 0.1))
        let moveGoki = SKAction.move(to: CGPoint(x:frame.size.width + 100, y: 100) , duration: TimeInterval(x))
        gokiSprite.run(moveGoki)
        addChild(gokiSprite)
    }

    func lightStand(){
        lightStandSprite = SKSpriteNode(imageNamed: "stand")
        lightStandSprite.position = CGPoint(x: frame.size.width/2 - 50, y:  frame.size.height/2)
        lightStandSprite.zPosition = 100
        lightStandSprite.setScale(magnification)
        addChild(lightStandSprite)
        lightZoneSprite = SKSpriteNode(imageNamed: "lightZone")
        lightZoneSprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2 - 100)
        lightZoneSprite.zPosition = 80
        lightZoneSprite.setScale(0.7)
        addChild(lightZoneSprite)
        lightStandTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(standTimer), userInfo: nil, repeats: true)
    }
    
    func standTimer(){
        standSecond += 1
        print("denkiSeconds = \(standSecond)")
        
        let difficult = difficulty()
        if (difficult == 1 && standSecond == 5) ||
            (difficult == 2 && standSecond == 3) ||
            (difficult == 3 && standSecond == 2) {
            lightStandTimer.invalidate()
            gameOverAlert(type: 1)
        }
        
    }
    
    func broken(){
        let x = decideDifficulty()
        ballSprite = SKSpriteNode(imageNamed: "ball")
        ballSprite.position = CGPoint(x: frame.size.width/2 - 120, y: frame.size.height/2 + 130)
        ballSprite.zPosition = 95
        ballSprite.setScale(0.01)
        
        // ballの動き
        let scaleFluctuationBall = SKAction.scale(to: 0.12, duration: TimeInterval(x))
        ballSprite.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        ballSprite.run(scaleFluctuationBall)
        addChild(ballSprite)
        
        ballTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(comeBallTimer), userInfo: nil, repeats: true)
    }
    
    func comeBallTimer(){
        ballSecond += 1
        if ballSecond == decideDifficulty() {
            windowSprite.removeFromParent()
            windowSprite = SKSpriteNode(imageNamed: "window_broken")
            windowSprite.position = CGPoint(x: frame.size.width/2 - 70, y: frame.size.height/2 + 100)
            windowSprite.zPosition = 98
            windowSprite.setScale(0.42)
            addChild(windowSprite)
            ballSprite.removeFromParent()
            gameOverAlert(type: 3)
        }
    }

/* ----- Event Function Zone fin ----- */

    
    
/* ----- Foundation Function zone -----*/
    func difficulty() -> Int{
        return userDefaults.integer(forKey: "DIFFICULT")
    }
    
    func decideDifficulty() -> Int{
        let difficult = difficulty()
        switch difficult {
        case 1:
            return 4
        case 2:
            return 2
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    func time(){
        timeLabel = SKLabelNode()
        timeLabel.fontColor = UIColor.black
        timeLabel.alpha = 1
        timeLabel.position = CGPoint(x: frame.size.width - 130, y: 10)
        timeLabel.text = "残り時間：\(remainingTime)秒"
        timeLabel.fontName = "Al-Bayan-Bold"
        timeLabel.horizontalAlignmentMode = .center
        timeLabel.zPosition = 100
        addChild(timeLabel)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdownTimer), userInfo: nil, repeats: true)
        eventTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(eventManagement), userInfo: nil, repeats: true)
    }
    
    func countdownTimer(){
        remainingTime -= 1
        score += 1
        if remainingTime == 0{
            gameClear = true
        }
        if remainingTime == -5 {
            timer.invalidate()
            gameSceneDelegate.dataSend(Score: score, Clear: gameFinish())
        }
        if(remainingTime >= 0){
            timeLabel.text = "残り時間：\(remainingTime)秒"
        }
    }
    
    func gameFinish() -> Int {
        if gameOver == true {
            return 1
        }
        else if gameClear == true {
            return 2
        }
        else {
            return 0
        }
    }
    
/* ----- Foundation Function zone fin -----*/
    
    
    
/* ----- Setup Function zone ----- */
    func setupSleepingMan(){
        manSprite = SKSpriteNode(imageNamed: "bed_boy_sleep")
        manSprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2 - 100)
        manSprite.setScale(magnification)
        manSprite.zPosition = 100
        addChild(manSprite)
    }

    func setupScoreLabel(){
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score : \(score)"
        self.addChild(scoreLabelNode)
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        bestScoreLabelNode.text = "Best : \(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    func setupTitleBackLabel(){
        // 背景の設定
        let titleBackSprite = SKSpriteNode(color: UIColor.cyan , size: CGSize(width: 150, height: 30))
        titleBackSprite.position = CGPoint(x: frame.size.width - 80, y: frame.size.height - 48)
        titleBackSprite.zPosition = 99
        addChild(titleBackSprite)
        
        let titleBackLabel = SKLabelNode()
        titleBackLabel.fontColor = UIColor.black
        titleBackLabel.alpha = 1
        titleBackLabel.position = CGPoint(x: frame.size.width - 80, y: frame.size.height - 60)
        titleBackLabel.text = "titleに戻る"
        titleBackLabel.fontName = "Al-Bayan-Bold"
        titleBackLabel.horizontalAlignmentMode = .center
        titleBackLabel.zPosition = 100
        addChild(titleBackLabel)
    }
    
    func setupDifficulty(){
        let difficult = difficulty()
        let difficultyLabel = SKLabelNode()
        difficultyLabel.fontColor = UIColor.black
        difficultyLabel.alpha = 1
        difficultyLabel.position = CGPoint(x: frame.size.width - 80, y: frame.size.height - 30)
        difficultyLabel.text = "difficulty:\(difficult)"
        difficultyLabel.fontName = "Al-Bayan-Bold"
        difficultyLabel.horizontalAlignmentMode = .center
        difficultyLabel.zPosition = 100
        addChild(difficultyLabel)
        
        //難易度によって難易度ラベルの背景色を変更
        var bg : SKSpriteNode!
        switch difficult {
        case 1:  bg = SKSpriteNode(color: UIColor.green  , size: CGSize(width: 150, height: 30))
        case 2:  bg = SKSpriteNode(color: UIColor.orange , size: CGSize(width: 150, height: 30))
        case 3:  bg = SKSpriteNode(color: UIColor.red    , size: CGSize(width: 150, height: 30))
        default: bg = SKSpriteNode(color: UIColor.black  , size: CGSize(width: 150, height: 30))
        }
        bg.position = CGPoint(x: frame.size.width - 80, y: frame.size.height - 20)
        bg.zPosition = 99
        addChild(bg)
    }
    
    func setupNightWindow(){
        backgroundColor = UIColor(colorLiteralRed: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        
        //夜の風景
        landscapeSprite = SKSpriteNode(imageNamed: "yoru")
        landscapeSprite.position = CGPoint(x: frame.size.width/2 - 70, y: frame.size.height/2 + 100)
        landscapeSprite.zPosition = 90
        landscapeSprite.setScale(magnification)
        addChild(landscapeSprite)
        
        // 窓
        windowSprite = SKSpriteNode(imageNamed: "window")
        windowSprite.position = CGPoint(x: frame.size.width/2 - 70, y: frame.size.height/2 + 100)
        windowSprite.zPosition = 98
        windowSprite.setScale(magnification)
        addChild(windowSprite)
    }
    
/* ----- setup function zone fin ----- */
    
}
