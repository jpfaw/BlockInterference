//
//  ViewController.swift
//  sleeping
//
//  Created by Yuta on 2016/10/22.
//  Copyright © 2016年 Yuta. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var difficult : Int = 0
    var audioPlayer:AVAudioPlayer!
    let userDefaults:UserDefaults = UserDefaults.standard
    
    // 難易度設定
    @IBAction func easy(_ sender: Any) {
        difficult = 1
        userDefaults.set(difficult, forKey: "DIFFICULT")
        audioPlayer.stop()
    }
    @IBAction func normal(_ sender: AnyObject) {
        difficult = 2
        userDefaults.set(difficult, forKey: "DIFFICULT")
        audioPlayer.stop()
    }
    @IBAction func hard(_ sender: AnyObject) {
        difficult = 3
        userDefaults.set(difficult, forKey: "DIFFICULT")
        audioPlayer.stop()
    }
    @IBOutlet weak var HighScoreLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do {
            let filePath = Bundle.main.path(forResource: "op", ofType: "mp3")
            let audioPath = NSURL(fileURLWithPath: filePath!)
            audioPlayer = try AVAudioPlayer(contentsOf: audioPath as URL)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        } catch {
            print("music error")
        }
        audioPlayer.play()
        //ハイスコア
        let highScore = userDefaults.integer(forKey: "BEST")
        HighScoreLabel.text = "High Score：\(highScore)"

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
