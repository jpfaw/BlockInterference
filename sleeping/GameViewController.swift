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
    
    let userDefaults:UserDefaults = UserDefaults.standard
    var score:Int = 0
    var clear:Int = 0

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
    func gameAlert(message: String) {
        
        let alertController = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
        let Action = UIAlertAction(title: "結果を見る", style: .default) {
            action in self.transition()
        }
        alertController.addAction(Action)
        present(alertController, animated: true, completion: nil)
    }
    
    //resultに遷移
    func transition(){
        userDefaults.set(score, forKey: "SCORE")
        userDefaults.set(clear, forKey: "CLEAR")
        userDefaults.synchronize()
        let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: "Result")
        targetViewController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        self.present(targetViewController, animated: true, completion: nil)
    }
    
    //@Delegate
    func dataSend(Score: Int, Clear: Int) {
        let highScore = userDefaults.integer(forKey: "BEST")
        if highScore < Score {
            userDefaults.set(Score, forKey: "BEST")
        }
        self.score = Score
        self.clear = Clear
        if Clear == 2 {
            self.transition()
        }
    }
    func returnTitle(){
        let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: "Title")
        self.present(targetViewController, animated: true, completion: nil)

    }
    
}

