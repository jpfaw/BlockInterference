//
//  ResultViewController.swift
//  sleeping
//
//  Created by Yuta on 2016/10/22.
//  Copyright © 2016年 Yuta. All rights reserved.
//

import UIKit
import AVFoundation

class ResultViewController: UIViewController, AVAudioPlayerDelegate {
    
    let userDefaults:UserDefaults = UserDefaults.standard
    var audioPlayer:AVAudioPlayer!
    
    @IBOutlet weak var normalScore: UILabel!
    @IBOutlet weak var clearBonus: UILabel!
    @IBOutlet weak var levelBonus: UILabel!
    @IBOutlet weak var totalScore: UILabel!
    @IBOutlet weak var highScore: UILabel!

    @IBOutlet weak var picture: UIImageView!

    @IBAction func returnTitle(_ sender: Any) {
        audioPlayer.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let filePath = Bundle.main.path(forResource: "result", ofType: "mp3")
            let audioPath = NSURL(fileURLWithPath: filePath!)
            audioPlayer = try AVAudioPlayer(contentsOf: audioPath as URL)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        } catch {
            print("music error")
        }
        audioPlayer.play()
        
        
        
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
        
        if clear == 1 {
            picture.image = UIImage(named: "nebusoku.png")
        }
        if clear == 2 {
            picture.image = UIImage(named: "nobi")
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
