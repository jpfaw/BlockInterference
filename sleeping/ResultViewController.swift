//
//  ResultViewController.swift
//  sleeping
//
//  Created by Yuta on 2016/10/22.
//  Copyright © 2016年 Yuta. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    let userDefaults:UserDefaults = UserDefaults.standard
    
    @IBOutlet weak var normalScore: UILabel!
    @IBOutlet weak var clearBonus: UILabel!
    @IBOutlet weak var levelBonus: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var highScore: UILabel!
    



    override func viewDidLoad() {
        super.viewDidLoad()
        let difficult = userDefaults.integer(forKey: "DIFFICULT")
        let highscore = userDefaults.integer(forKey: "BEST")
        let score = userDefaults.integer(forKey: "SCORE")
        let clear = userDefaults.integer(forKey: "CLEAR")
        var clearbonus = 0
        if clear == 2 {
            clearbonus = 100
        }
        let levelbonus = difficult * 100
        let total = score + clearbonus + levelbonus
        if highscore < total {
            userDefaults.set(total, forKey: "BEST")
            userDefaults.synchronize()
        }
        
        normalScore.text    = "：\(score)"
        clearBonus.text     = "：\(clearbonus)"
        levelBonus.text     = "：\(levelbonus)"
        totalScore.text     = "：\(total)"
        highScore.text      = "：\(highscore)"
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //status barの削除
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
