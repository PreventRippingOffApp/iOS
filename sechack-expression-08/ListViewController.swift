//
//  ListViewController.swift
//  sechack-expression-08
//
//  Created by 吉川莉央 on 2019/08/03.
//  Copyright © 2019 RioYoshikawa. All rights reserved.
//

import UIKit
import AVFoundation

class ListViewController: UITableViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
//    var tableView: UITableView!
    
    var audioPlayer: AVAudioPlayer!
    var isPlaying = false
    
    var url : URL?
    var urlArray: [URL] = []
    let userDefaults = UserDefaults.standard
//    var userDefaultsIsNil: Bool = true
    
    var audioFileArray: [String] = [] //録音したaudio fileの管理
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        if userDefaultsIsNil == false {
            audioFileArray = userDefaults.array(forKey: "stringsArray") as! [String]
            print(audioFileArray)
            tableView.reloadData()
            for i in audioFileArray {
                let getURL = userDefaults.url(forKey: i)
                print(getURL)
                urlArray.append(getURL!)
            }
        }

        // Do any additional setup after loading the view.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !isPlaying {
            
            audioPlayer = try! AVAudioPlayer(contentsOf: urlArray[indexPath.row])
            audioPlayer.delegate = self
            audioPlayer.play()
            
            isPlaying = true
            
        }else{
            
            audioPlayer.stop()
            isPlaying = false
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFileArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        cell!.textLabel?.text = audioFileArray[indexPath.row]
        
        return cell!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
