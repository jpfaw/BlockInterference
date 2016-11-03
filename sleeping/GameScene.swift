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
    
    
    
    
    
    override func didMove(to view: SKView) {

        let difficult = difficulty()
        
        
        // 背景色
        backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)
        // setup function
        setupScoreLabel()
        setupTitleBackLabel()
        
        
        let titleLabel = SKLabelNode()
        titleLabel.fontColor = UIColor.black
        //titleLabel.fontSize = 20
        titleLabel.alpha = 1
        titleLabel.position = CGPoint(x: frame.size.width - 80, y: frame.size.height - 30)
        titleLabel.text = "difficulty : \(difficult)"
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 100
        addChild(titleLabel)
        

        
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
        bestScoreLabelNode.text = "Best Score : \(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    func setupTitleBackLabel(){
        
        let titleBackSprite = SKSpriteNode(color: UIColor.orange , size: CGSize(width: 150, height: 30))
        titleBackSprite.position = CGPoint(x: frame.size.width - 80, y: frame.size.height - 48)
        titleBackSprite.zPosition = 99
        addChild(titleBackSprite)
 
        let titleBackLabel = SKLabelNode()
        titleBackLabel.fontColor = UIColor.black
        titleBackLabel.alpha = 1
        titleBackLabel.position = CGPoint(x: frame.size.width - 80, y: frame.size.height - 60)
        titleBackLabel.text = "titleに戻る"
        titleBackLabel.horizontalAlignmentMode = .center
        titleBackLabel.zPosition = 100
        addChild(titleBackLabel)
 
    }
    

}
