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
        sendGame()
    }
    @IBAction func normal(_ sender: AnyObject) {
        difficult = 2
        sendGame()
    }
    @IBAction func hard(_ sender: AnyObject) {
        difficult = 3
        sendGame()
    }
    
    @IBOutlet weak var HighScoreLabel: UILabel!
    
    var titleLogo:UIImageView!
    
    func sendGame(){
        userDefaults.set(difficult, forKey: "DIFFICULT")
        audioPlayer.stop()
        let gamePage = GameViewController()
        self.navigationController?.pushViewController(gamePage, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        do {
            let filePath = Bundle.main.path(forResource: "op", ofType: "mp3")
            let audioPath = NSURL(fileURLWithPath: filePath!)
            audioPlayer = try AVAudioPlayer(contentsOf: audioPath as URL)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        } catch {
            print("music error")
        }
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ハイスコア
        let highScore = userDefaults.integer(forKey: "BEST")
        HighScoreLabel.text = "High Score：\(highScore)"
        
        // logo
        let logo = UIImage(named:"logo")!
        titleLogo = UIImageView(image:logo)
        let rect:CGRect = CGRect(x:0, y:0, width:self.view.bounds.width - 30, height:logo.size.height * 1.5)
        titleLogo.frame = rect;
        titleLogo.alpha = 0.0
        titleLogo.center = CGPoint(x:self.view.bounds.width/2, y:150)
        self.view.addSubview(titleLogo)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            UIView.animate(withDuration: 3.0) { () -> Void in
                self.titleLogo.alpha = 1.0
            }
        }

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
