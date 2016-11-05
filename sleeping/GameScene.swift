//
//  GameScene.swift
//  sleeping
//
//  Created by Yuta on 2016/11/03.
//  Copyright © 2016年 Yuta. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {
    
    //データの取り扱い
    let userDefaults:UserDefaults = UserDefaults.standard
    
    let scoreCategory: UInt32 = 1 << 0
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
    
    // check
    var gameNow = true                  // ゲーム中なら true
    var denkiCheck = false              // 電気がついてたら true
    
    var remainingTime = 5
    var timer = Timer()
    var eventTimer = Timer()
    var timerBehavior = false //未使用
    
    let magnification:CGFloat = 0.5
    
    
    
    
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
        
        //その他（実装中）
        time() //time内でeventManagementを起動
        denkiOff()
        
    }
    

    func denkiOn(){
        let denkiTexture = SKTexture(imageNamed: "light_on")
        denkiTexture.filteringMode = SKTextureFilteringMode.nearest //画質荒い：動作早い
        denkiSprite = SKSpriteNode(imageNamed: "light_on")
        denkiSprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height - 70)
        denkiSprite.zPosition = 100
        denkiSprite.setScale(1.5)
        addChild(denkiSprite)
        
        let switchTexture = SKTexture(imageNamed: "switch_on")
        switchTexture.filteringMode = SKTextureFilteringMode.nearest
        switchSprite = SKSpriteNode(imageNamed: "switch_on")
        switchSprite.position = CGPoint(x: 50, y: frame.size.height/2 - 60)
        switchSprite.zPosition = 100
        switchSprite.setScale(0.3)
        addChild(switchSprite)
    }
    
    func denkiOff(){
        let denkiTexture = SKTexture(imageNamed: "light_off")
        denkiTexture.filteringMode = SKTextureFilteringMode.nearest //画質荒い：動作早い
        denkiSprite = SKSpriteNode(imageNamed: "light_off")
        denkiSprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height - 70)
        denkiSprite.zPosition = 100
        denkiSprite.setScale(1.5)
        addChild(denkiSprite)
        
        let switchTexture = SKTexture(imageNamed: "switch_off")
        switchTexture.filteringMode = SKTextureFilteringMode.nearest
        switchSprite = SKSpriteNode(imageNamed: "switch_off")
        switchSprite.position = CGPoint(x: 50, y: frame.size.height/2 - 60)
        switchSprite.zPosition = 100
        switchSprite.setScale(0.3)
        addChild(switchSprite)    }

    



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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view?.isMultipleTouchEnabled = true
        
        // 一つの情報を取り出します
        for touch in touches {
            let location = touch.location(in: self)
            let touchNodes = self.nodes(at: location)
            for tNode in touchNodes {
                if tNode == switchSprite{
                    switchDenki()
                }
            }
        }
    }
    
    func switchDenki(){
        if gameNow == true {
            switchSprite.removeFromParent()
            denkiSprite.removeFromParent()
            if denkiCheck == false {
                denkiOn()
                backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)
                denkiCheck = true
            }else{
                denkiOff()
                backgroundColor = UIColor(colorLiteralRed: 0.7, green: 0.7, blue: 0.7, alpha: 1)
                denkiCheck = false
            }
        }
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
    
/* ----- Event Function Zone fin ----- */

    
    
/* ----- Foundation Function zone -----*/
    func difficulty() -> Int{
        return userDefaults.integer(forKey: "DIFFICULT")
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
