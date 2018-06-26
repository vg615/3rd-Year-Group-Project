//
//  SecondViewController.swift
//  ADAS2
//
//  Created by JwLwJ on 05/05/2018.
//  Copyright © 2018 JwLwJ. All rights reserved.
//
import UIKit
import AVFoundation

var songs:[String] = []
var audioPlayer = AVAudioPlayer()
var audioPlayerTimer = Timer()



class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var myTableView: UITableView!
    var  nameText = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "myKey")
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = songs[indexPath.row]
        if(cell.textLabel?.text == token){
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do{
            
            let audioPath = Bundle.main.path(forResource: songs[indexPath.row], ofType: ".mp3")
            nameText = songs[indexPath.row]
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            for row in 0..<tableView.numberOfRows(inSection: indexPath.section) {
                if let cell = tableView.cellForRow(at: IndexPath(row: row, section: indexPath.section)) {
                    cell.accessoryType = row == indexPath.row ? .checkmark : .none
                }
            }
            //tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            
            let defaults = UserDefaults.standard
            defaults.set(nameText, forKey: "myKey")
            defaults.synchronize()
            print("歌曲已经选定")
        }
        catch{
            print("ERROR")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gettingSongNmae()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gettingSongNmae(){
        // get all of the songs that in the folder
        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        
        do {
            let songPath = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            // have all of our files stored in constant array songPath
            
        
            for song in songPath{
                //loop through constant
                var mySong = song.absoluteString
                
                if mySong.contains(".mp3"){
                    let findString = mySong.components(separatedBy: "/")
                    mySong = findString[findString.count-1]
                    mySong = mySong.replacingOccurrences(of: "%20", with: " ")
                    mySong = mySong.replacingOccurrences(of: ".mp3", with: "")
                    songs.append(mySong)
                }
            }

            myTableView.reloadData()
            
        }
        catch{
             print("ERROR")
        }
    }
    
    
}
