//
//  FirstViewController.swift
//  ADAS2
//
//  Created by JwLwJ on 05/05/2018.
//  Copyright © 2018 JwLwJ. All rights reserved.
//

import UIKit
import AVFoundation

class FirstViewController: UIViewController {

  
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "myKey")
        
        
        do{
            
            let audioPath1 = Bundle.main.path(forResource: token, ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath1!) as URL)
            print(token)
            
            if(token) == nil{
                let audioPath1 = Bundle.main.path(forResource: "Bon Jovi-It's My Life", ofType: ".mp3")
                try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath1!) as URL)
            }
        }catch{
            print("ERROR")
        }
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func StopMusic(_ sender: Any) {
        audioPlayer.currentTime = 0
        audioPlayer.stop()
    }
    
        @IBAction func click_button(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let BLE = storyboard.instantiateViewController(withIdentifier: "BLECentralViewController")as!
        BLECentralViewController
        self.navigationController?.pushViewController(BLE, animated: true)
    }
 
    

}

