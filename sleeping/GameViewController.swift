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
        let scene = GameScene(size: skView.frame.size)
        scene.gameSceneDelegate = self
        skView.presentScene(scene)
    }
    override func loadView() {
        let mySize: CGSize = UIScreen.main.bounds.size
        self.view = SKView(frame: CGRect(x: 0, y: 0, width: mySize.width, height: mySize.height))
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
        let Action = UIAlertAction(title: "総合成績を見る", style: .default) {
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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultPage = storyboard.instantiateViewController(withIdentifier: "Result")
        navigationController?.pushViewController(resultPage, animated: true)

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
        _ = navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
}

