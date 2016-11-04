//
//  ViewController.swift
//  sleeping
//
//  Created by Yuta on 2016/10/22.
//  Copyright © 2016年 Yuta. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    var difficult : Int = 0
    
    // 難易度設定
    @IBAction func easy(_ sender: Any) {
        difficult = 1
        userDefaults.set(difficult, forKey: "DIFFICULT")
    }
    @IBAction func normal(_ sender: AnyObject) {
        difficult = 2
        userDefaults.set(difficult, forKey: "DIFFICULT")
    }
    @IBAction func hard(_ sender: AnyObject) {
        difficult = 3
        userDefaults.set(difficult, forKey: "DIFFICULT")
    }

    @IBOutlet weak var HighScoreLabel: UILabel!
    
    
    let userDefaults:UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //ハイスコア
        let highScore = userDefaults.integer(forKey: "BEST")
        HighScoreLabel.text = "High Score：\(highScore)"
        
        //更新されてた時用メモ
//        userDefaults.setInteger(bestScore, forKey: "BEST")
//        userDefaults.synchronize()
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //難易度を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let gameViewController:GameViewController = segue.destination as! GameViewController
        gameViewController.difficult = difficult
    }

    //status barの削除
    override var prefersStatusBarHidden: Bool {
        return true
    }


}
