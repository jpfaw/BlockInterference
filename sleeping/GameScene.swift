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

    var difficult:Int = 0
    
    override func didMove(to view: SKView) {

        difficulty()
        
        
        //背景色
        backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)
        
        let titleLabel = SKLabelNode(fontNamed: "SnellRoundhand-Black")
        titleLabel.fontColor = UIColor.black
        titleLabel.fontSize = 32
        titleLabel.alpha = 1
        titleLabel.position = CGPoint(x: frame.size.width/2, y: frame.size.height - 30)
        titleLabel.text = "difficulty : \(difficult)"
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 100
        addChild(titleLabel)
        
        
        
    }
    
    func difficulty(){
        let userDefaults:UserDefaults = UserDefaults.standard
        difficult = userDefaults.integer(forKey: "DIFFICULT")
    }
    

}
