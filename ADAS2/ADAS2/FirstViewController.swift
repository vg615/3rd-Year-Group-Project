//
//  FirstViewController.swift
//  ADAS2
//
//  Created by JwLwJ on 05/05/2018.
//  Copyright © 2018 JwLwJ. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        var alert = UIAlertController(title: "Alert!", message: "Bluetooth Not Connected", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated:true, completion:nil)
    }
    

}

