//
//  GameScene.swift
//  sleeping
//
//  Created by Yuta on 2016/11/03.
//  Copyright © 2016年 Yuta. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

protocol GameSceneDelegate {
    func gameAlert(message : String)
    func dataSend(Score: Int, Clear: Int)
    func returnTitle()
}

class GameScene: SKScene{
    var gameSceneDelegate: GameSceneDelegate!
    
/* ----- variable management zone ----- */
    // important
    let userDefaults:UserDefaults = UserDefaults.standard
    var remainingTime = 30              // イベント時間
    
    var score = 0
    var bestScore = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var titleBackLabel:SKLabelNode!
    var timeLabel:SKLabelNode!
    
    // Item SpriteNode
    var bgSprite:SKSpriteNode!
    var bgYSprite:SKSpriteNode!
    var titleBackSprite:SKSpriteNode!   //タイトルの背景
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
    
    // music
    let BGM = SKAudioNode.init(fileNamed: "BGM.mp3")
    let chicken = SKAudioNode.init(fileNamed: "chicken.mp3")
    let mezamasiAudio = SKAudioNode.init(fileNamed: "mezamasi.mp3")
    let mezamasiStop = SKAudioNode.init(fileNamed: "mezamasiStop.mp3")
    let switchAudio = SKAudioNode.init(fileNamed: "switch.mp3")
    let ballCome = SKAudioNode.init(fileNamed: "rakka.mp3")
    let garasBroken = SKAudioNode.init(fileNamed: "ware.mp3")
    let kasakasa = SKAudioNode.init(fileNamed: "kasakasa.mp3")
    let syupon = SKAudioNode.init(fileNamed: "syupon.mp3")
    
    
    
/* ----- variable management zone fin ----- */
    
    
    override func didMove(to view: SKView) {
        
        // setup
        let difficult = decideDifficulty()
        bestScore = userDefaults.integer(forKey: "BEST")
        physicsWorld.gravity = CGVector(dx: Double(5 - difficult)*0.07, dy: Double(5 - difficult)*(-0.05))
        self.addChild(BGM)
        
        // audio loop false
        switchAudio.autoplayLooped = false
        mezamasiStop.autoplayLooped = false
        ballCome.autoplayLooped = false
        garasBroken.autoplayLooped = false
        syupon.autoplayLooped = false
        
        // setup function
        setupScoreLabel()
        setupTitleBackLabel()
        setupDifficulty()
        setupNightWindow()
        setupSleepingMan()
        setupBackGround()
        
        // Initial set
        time() //time内でeventManagementを起動
        denkiOff()

    }
    


    func eventManagement(){
        let difficult = difficulty()
        let nowData = (difficult, remainingTime)
        var random = decideRandom(min: 1, max: 7)
        if random == 6 || random == 7 {
            random = decideRandom(min: 1, max: 9)
        }
        
        if remainingTime == 0{
            morning()
            wakeupMan()
            eventTimer.invalidate()
            bgSprite.alpha = 1
            bgYSprite.alpha = 1
        }else{
            if difficult == 1 && remainingTime % 5 == 0 {
                eventOccur(type: random)
            }else if difficult == 2 && remainingTime % 4 == 0 {
                eventOccur(type: random)
            }else if difficult == 3 && remainingTime % 2 == 0 {
                eventOccur(type: random)
            }
        }

        // その他イベント
        print("nowData:\(nowData)")
        if score > bestScore {
            bestScore = score
        }
        scoreLabelNode.text = "Score : \(score)"
        bestScoreLabelNode.text = "Best : \(bestScore)"
    }
    
    func eventOccur(type :Int){
        switch type {
        case 1:
            callMezamasi()
        case 2:
            goki()
        case 3:
            lightStand()
        case 4:
            broken()
        case 5:
            switchDenki()
        default:
            print("event default")
        }
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
                    kasakasa.removeFromParent()
                    gokiSprite.removeFromParent()
                    score += difficult * 100
                }
                // 目覚まし時計
                if mezamasiSprite != nil && tNode == mezamasiSprite {
                    mezamasiSprite.removeFromParent()
                    mezamasiAudio.removeFromParent()
                    mezamasiStop.removeFromParent()
                    mezamasiTimer.invalidate()
                    mezamasiSeconds = 0
                    score += 100
                    
                    let playAction = SKAction.play()
                    mezamasiStop.run(playAction)
                    self.addChild(mezamasiStop)
                }
                // 電気スタンド
                if lightStandSprite != nil && tNode == lightStandSprite {
                    lightStandSprite.removeFromParent()
                    lightZoneSprite.removeFromParent()
                    switchAudio.removeFromParent()
                    lightStandTimer.invalidate()
                    standSecond = 0
                    score += 100
                    
                    let playAction = SKAction.play()
                    switchAudio.run(playAction)
                    self.addChild(switchAudio)
                }
                // broken
                if ballSprite != nil && tNode == ballSprite {
                    ballSprite.removeFromParent()
                    ballCome.removeFromParent()
                    syupon.removeFromParent()
                    ballTimer.invalidate()
                    ballSecond = 0
                    score += 200 + difficult * 10
                    
                    let playAction = SKAction.play()
                    syupon.run(playAction)
                    self.addChild(syupon)
                }
                // titleに戻る
                if tNode == titleBackSprite {
                    timer.invalidate()
                    eventTimer.invalidate()
                    BGM.removeFromParent()
                    gameSceneDelegate.returnTitle()
                }
                scoreLabelNode.text = "Score : \(score)"
            }
        }
    }
    

    
    func gameOverAlert(type: Int){
        timer.invalidate()
        eventTimer.invalidate()
        BGM.removeFromParent()

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
        denkiSprite.removeFromParent()
        //朝の風景
        landscapeSprite = SKSpriteNode(imageNamed: "asa")
        landscapeSprite.position = CGPoint(x: frame.size.width/2 - 70, y: frame.size.height/2 + 100)
        landscapeSprite.zPosition = 97
        landscapeSprite.setScale(magnification)
        addChild(landscapeSprite)
        
        // 朝用電気
        denkiSprite = SKSpriteNode(imageNamed: "lightM")
        denkiSprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height - 70)
        denkiSprite.zPosition = -10
        denkiSprite.setScale(1.5)
        addChild(denkiSprite)
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
        if gameClear != true {
            switchAudio.removeFromParent()
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
            
            let playAction = SKAction.play()
            switchAudio.run(playAction)
            self.addChild(switchAudio)
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
        addChild(mezamasiAudio)
        
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
            mezamasiAudio.removeFromParent()
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
        
        let playAction = SKAction.play()
        kasakasa.run(playAction)
        self.addChild(kasakasa)
        
        // delay
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(x)) {
            self.kasakasa.removeFromParent()
            self.gokiSprite.removeFromParent()
        }
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
        
        switchAudio.removeFromParent()
        let playAction = SKAction.play()
        switchAudio.run(playAction)
        self.addChild(switchAudio)
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
        
        ballCome.removeFromParent()
        let playAction = SKAction.play()
        ballCome.run(playAction)
        self.addChild(ballCome)
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
            
            BGM.removeFromParent()
            ballCome.removeFromParent()
            let playAction = SKAction.play()
            garasBroken.run(playAction)
            self.addChild(garasBroken)
            
            // delay
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.gameOverAlert(type: 3)
            }
           
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
        if remainingTime == 0{
            gameClear = true
            BGM.removeFromParent()
            chicken.autoplayLooped = false
            let playAction = SKAction.play()
            chicken.run(playAction)
            self.addChild(chicken)
        }
        if remainingTime == -5 {
            timer.invalidate()
            chicken.removeFromParent()
            removeAllActions()
            removeAllChildren()
            gameSceneDelegate.dataSend(Score: score, Clear: gameFinish())
        }
        if(remainingTime >= 0){
            score += 1
            timeLabel.text = "残り時間：\(remainingTime)秒"
        }
        scoreLabelNode.text = "Score : \(score)"
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
    
    func decideRandom(min: Int, max: Int) -> Int {
        if min < max {
            let diff = max - min + 1
            let random : Int = Int(arc4random_uniform(UInt32(diff)))
            return random + min
        }else {
            print("error")
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
        titleBackSprite = SKSpriteNode(color: UIColor.cyan , size: CGSize(width: 150, height: 30))
        titleBackSprite.position = CGPoint(x: frame.size.width - 80, y: frame.size.height - 48)
        titleBackSprite.zPosition = 99
        addChild(titleBackSprite)
        
        titleBackLabel = SKLabelNode()
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
    
    func setupBackGround(){
        bgSprite = SKSpriteNode(imageNamed: "roomBG")
        bgSprite.position = CGPoint(x: 0, y: size.height)
        bgSprite.zPosition = -20
        bgSprite.setScale(4.5)
        bgSprite.alpha = 0.4
        addChild(bgSprite)
        
        bgYSprite = SKSpriteNode(imageNamed: "roomYuka")
        bgYSprite.position = CGPoint(x: 0, y: size.height / 3)
        bgYSprite.zPosition = -30
        bgYSprite.setScale(5)
        bgYSprite.alpha = 0.5
        addChild(bgYSprite)
    }

/* ----- setup function zone fin ----- */
    
}
