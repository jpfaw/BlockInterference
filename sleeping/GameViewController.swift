//
//  GameViewController.swift
//  sleeping
//
//  Created by Yuta on 2016/10/22.
//  Copyright © 2016年 Yuta. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameSceneDelegate {
    
    var difficult:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        let scene = GameScene(size: skView.frame.size)
        scene.gameSceneDelegate = self
        skView.presentScene(scene)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //status barの削除
    override var prefersStatusBarHidden: Bool {
        return true
    }
    //@Delegate
    func translate() {
        
    }
    //@Delegate
    func gameAlert(message: String) {
        
        let alertController = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "はい", style: .default) {
            action in NSLog("はいボタンが押されました")
        }
        alertController.addAction(otherAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

