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
    
    
    
    
    
    override func didMove(to view: SKView) {

        // 背景色
        backgroundColor = UIColor(colorLiteralRed: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        
        // setup function
        setupScoreLabel()
        setupTitleBackLabel()
        setupDifficulty()
        
        //その他（実装中）
        windowNode()
        sleepingMan()
        night()
        time()
    }
    
    func difficulty() -> Int{
        return userDefaults.integer(forKey: "DIFFICULT")
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
    
    func windowNode(){
        let windowTexture = SKTexture(imageNamed: "curtain_pink")
        windowTexture.filteringMode = SKTextureFilteringMode.nearest //画質荒い：動作早い
        let windowSprite = SKSpriteNode(texture: windowTexture)
        windowSprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2 + 100)
        windowSprite.zPosition = 98
        windowSprite.setScale(0.3)
        addChild(windowSprite)
    }
    
    func sleepingMan(){
        let manTexture = SKTexture(imageNamed: "suimin_man")
        manTexture.filteringMode = SKTextureFilteringMode.nearest //画質荒い：動作早い
        let manSprite = SKSpriteNode(texture: manTexture)
        manSprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2 )
        manSprite.setScale(0.3)
        addChild(manSprite)
    }
    
    func night(){
        let nightTexture = SKTexture(imageNamed: "yoru")
        nightTexture.filteringMode = SKTextureFilteringMode.nearest //画質荒い：動作早い
        let nightSprite = SKSpriteNode(texture: nightTexture)
        nightSprite.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2 + 100)
        nightSprite.zPosition = 97
        nightSprite.setScale(0.3)
        addChild(nightSprite)
    }
    
    var remainingTime = 60
    var timer = Timer()
    
    func countdownTimer(){
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdownTimer), userInfo: nil, repeats: false)
        remainingTime -= 1
        if remainingTime <= 0 {
            remainingTime = 0
        }
        print(remainingTime)
        //timeLabel.text = "残り時間：\(remainingTime)秒"
        //addChild(timeLabel)
            }
    
    func time(){
        let timeLabel = SKLabelNode()
        timeLabel.fontColor = UIColor.black
        timeLabel.alpha = 1
        timeLabel.position = CGPoint(x: frame.size.width - 130, y: 10)
        timeLabel.text = "残り時間：\(remainingTime)秒"
        timeLabel.fontName = "Al-Bayan-Bold"
        timeLabel.horizontalAlignmentMode = .center
        timeLabel.zPosition = 100
        addChild(timeLabel)
        
        countdownTimer()
    }
    

}
