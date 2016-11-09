//
//  GameScene.swift
//  sleeping
//
//  Created by Yuta on 2016/11/03.
//  Copyright © 2016年 Yuta. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene{
    
/* ----- variable management zone ----- */
    // important
    let userDefaults:UserDefaults = UserDefaults.standard
    var remainingTime = 10               // イベント時間 通常60s
    
    let scoreCategory: UInt32 = 1 << 0  // 未実装
    var score = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var TitleBackLabel:SKLabelNode!
    var timeLabel:SKLabelNode!
    
    // Item SpriteNode
    var nightSprite:SKSpriteNode!       // 夜の背景
    var windowSprite:SKSpriteNode!      // 窓枠
    var manSprite:SKSpriteNode!         // 寝てる人
    var denkiSprite:SKSpriteNode!       // 電気
    var switchSprite:SKSpriteNode!      // 電気のスイッチ
    var mezamasiSprite:SKSpriteNode!    // 目覚まし
    var gokiSprite:SKSpriteNode!        // goki
    var lightStandSprite:SKSpriteNode!   // 電気スタンド
    var lightZoneSprite:SKSpriteNode!
    
    // check
    var gameNow = true                  // ゲーム中なら true
    var denkiCheck = false              // 電気がついてたら true
    var gameOver = false
    
    
    
    // timer
    var timer = Timer()                 // ゲームの残り時間
    var eventTimer = Timer()            // eventManagerへ毎秒アクセス
    var denkiTimer = Timer()            // 電気が入ってから何秒経ったか計測
    var mezamasiTimer = Timer()         // 目覚ましが鳴っている時間
    var lightStandTimer = Timer()       // ライトスタンドがついている時間
    var timerBehavior = false           // 未使用
    
    let magnification:CGFloat = 0.5     // オブジェクトの倍率管理
    var denkiSeconds = 0                // 電気つけて経った時間
    var mezamasiSeconds = 0             // 目覚まし鳴ってからの時間
    var standSecond = 0                 // 電気スタンドがついている時間
    
/* ----- variable management zone fin ----- */
    
    
    override func didMove(to view: SKView) {
        /* memo
         *
         * 背景色は各window関数の中
         *
         */
        
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
        
        // 実装予定イベント
        // broken
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
                    scoreLabelNode.text = "Score : \(score)"
                }
                // 目覚まし時計
                if mezamasiSprite != nil && tNode == mezamasiSprite {
                    mezamasiSprite.removeFromParent()
                    mezamasiTimer.invalidate()
                    mezamasiSeconds = 0
                    score += 100
                    scoreLabelNode.text = "Score : \(score)"
                }
                // 電気スタンド
                if lightStandSprite != nil && tNode == lightStandSprite {
                    lightStandSprite.removeFromParent()
                    lightZoneSprite.removeFromParent()
                    lightStandTimer.invalidate()
                    standSecond = 0
                    score += 100
                    scoreLabelNode.text = "Score : \(score)"
                }
            }
        }
    }
    

    


    
    func gameOverAlert(type: Int){
        timer.invalidate()
        eventTimer.invalidate()
        
        let alert = UIAlertView()
        alert.title = "Game Over"
        
        switch type {
        case 1: alert.message = "眩しくて起きた"
        case 2: alert.message = "目覚ましで起きた"
        default: alert.message = "想定されていないエラー番号です"
        }
        
        alert.addButton(withTitle: "OK")
        alert.show()
    }
    
    
/* ----- Event Function Zone ----- */
    func morning(){
        backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)

        nightSprite.removeFromParent()
        //朝の風景
        let morningSprite = SKSpriteNode(imageNamed: "asa")
        morningSprite.position = CGPoint(x: frame.size.width/2 - 70, y: frame.size.height/2 + 100)
        morningSprite.zPosition = 97
        morningSprite.setScale(magnification)
        addChild(morningSprite)
        
        //朝の窓
        windowSprite = SKSpriteNode(imageNamed: "window")
        windowSprite.position = CGPoint(x: frame.size.width/2 - 70, y: frame.size.height/2 + 100)
        windowSprite.zPosition = 98
        windowSprite.setScale(magnification)
        addChild(windowSprite)
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
        denkiSprite.zPosition = 100
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
        denkiSprite.zPosition = 100
        denkiSprite.setScale(1.5)
        addChild(denkiSprite)
        
        switchSprite = SKSpriteNode(imageNamed: "switch_off")
        switchSprite.position = CGPoint(x: 50, y: frame.size.height/2 - 60)
        switchSprite.zPosition = 100
        switchSprite.setScale(0.3)
        addChild(switchSprite)
    }
    
    func switchDenki(){
        if gameNow == true {
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
    }
    
    func denkiCount(){
        denkiSeconds += 1
        print("denkiSeconds = \(denkiSeconds)")
        
        let difficult = difficulty()
        if (difficult == 1 && denkiSeconds == 5) ||
           (difficult == 2 && denkiSeconds == 3) ||
           (difficult == 3 && denkiSeconds == 2) {
            denkiTimer.invalidate()
            gameNow = false
            gameOver = true
            gameOverAlert(type: 1)
        }
    }
    
    func callMezamasi(){
        let mezamasiTextureA = SKTexture(imageNamed: "mezamasi_1")
        mezamasiTextureA.filteringMode = SKTextureFilteringMode.linear
        let mezamasiTextureB = SKTexture(imageNamed: "mezamasi_2")
        mezamasiTextureB.filteringMode = SKTextureFilteringMode.linear
        
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
            gameNow = false
            gameOver = true
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
            gameNow = false
            gameOver = true
            gameOverAlert(type: 1)
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
            gameNow = false
        }
        if remainingTime == -10 {
            timer.invalidate()
        }
        if(remainingTime >= 0){
            timeLabel.text = "残り時間：\(remainingTime)秒"
        }
    }
    
/* ----- Foundation Function zone fin -----*/
    
    
    
/* ----- Setup Function zone ----- */
    func setupSleepingMan(){
        let manTexture = SKTexture(imageNamed: "bed_boy_sleep")
        manTexture.filteringMode = SKTextureFilteringMode.nearest //画質荒い：動作早い
        manSprite = SKSpriteNode(texture: manTexture)
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
        let nightTexture = SKTexture(imageNamed: "yoru")
        nightTexture.filteringMode = SKTextureFilteringMode.nearest
        nightSprite = SKSpriteNode(texture: nightTexture)
        nightSprite.position = CGPoint(x: frame.size.width/2 - 70, y: frame.size.height/2 + 100)
        nightSprite.zPosition = 96
        nightSprite.setScale(magnification)
        addChild(nightSprite)
    }
    
/* ----- setup function zone fin ----- */
    
}
