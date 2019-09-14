//
//  ViewController.swift
//  sechack-expression-08
//
//  Created by 吉川莉央 on 2019/07/30.
//  Copyright © 2019 RioYoshikawa. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import CoreLocation
// get Location data (https://qiita.com/chino_tweet/items/db3a536234a43a3c31d9)

var userDefaultsIsNil: Bool = true

struct Manager
{
    //Required Objects - AVFoundation
    ///AVAudio Session
    static var recordingSession: AVAudioSession!
    
    ///AVAudio Recorder
    static var recorder: AVAudioRecorder?
}

class ViewController: UIViewController , AVAudioRecorderDelegate, AVAudioPlayerDelegate, CLLocationManagerDelegate
{

//    @IBOutlet var label: UILabel!
//    @IBOutlet var recordButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var locationManager: CLLocationManager!
    var isRecording = false
    var isPlaying = false
    
    
    //データ保存関係の変数
    var url : URL?
    var urlArray: [URL] = []
    let userDefaults = UserDefaults.standard
    
//    録音したaudio fileの管理
    var audioFileArray: [String] = []
    
//    storyboard
    let recordButton = UIButton()
    var screenWidth:CGFloat = 0
    var screenHeight:CGFloat = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        // Do any additional setup after loading the view.
        userDefaults.register(defaults: ["nilFlag" : true])
        userDefaultsIsNil = userDefaults.bool(forKey: "nilFlag")
        
        
//        storybboard
        // 画面の横幅を取得
        screenWidth = view.frame.size.width
        screenHeight = view.frame.size.height
        

        recordButton.frame = CGRect(x:screenWidth/2-screenWidth/4,y:screenHeight/2-screenHeight/4,
                              width:screenWidth/2, height:screenHeight/2)
        recordButton.setImage(UIImage(named: "record"), for: .normal)
        // Aspect Fit
        recordButton.imageView?.contentMode = .scaleAspectFit
        // Horizontal 拡大
        recordButton.contentHorizontalAlignment = .fill
        // Vertical 拡大
        recordButton.contentVerticalAlignment = .fill
        
        // ViewにButtonを追加
        self.view.addSubview(recordButton)
        
        // タップされたときのactionをセット
        recordButton.addTarget(self, action: #selector(ViewController.record),
                         for: .touchUpInside)
        
        // 背景色を設定
        self.view.backgroundColor = UIColor(displayP3Red: 0.937,
                                            green: 0.894, blue: 1.0, alpha: 1.0)
        /*
        let getLocationButton = UIButton(type: UIButton.ButtonType.system)
        getLocationButton.addTarget(self, action: #selector(buttonEvent(_:)), for: UIControl.Event.touchUpInside)
        getLocationButton.setTitle("テストボタン", for: UIControl.State.normal)
        
        getLocationButton.sizeToFit()
        getLocationButton.center = self.view.center
        self.view.addSubview(getLocationButton)
 */

    }
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
        print("status:\(status)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        
        print("latitude: \(latitude!)\nlongitude: \(longitude!)")
    }
    
    @objc func buttonEvent(_ sender: UIButton){
        print("ボタンの情報: \(sender)")
    }


    @objc func record(_ sender:UIButton){
        if !isRecording {
            
            let session = AVAudioSession.sharedInstance()
            
            do {
                try session.setCategory(AVAudioSession.Category.playAndRecord)
            } catch  {
                fatalError("category err")
            }
            
            do {
                try session.setActive(true)
            } catch {
                fatalError("session activate err")
            }
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
 
            do {
                audioRecorder = try AVAudioRecorder(url: getURL(), settings: settings)
            } catch {
                audioRecorder = nil
            }
            
            audioRecorder.delegate = self
            //再生
            audioRecorder.record()
            isRecording = true
            
            recordButton.setImage(UIImage(named: "stop"), for: .normal)
            
//            label.text = "録音中"
//            recordButton.setTitle("STOP", for: .normal)
//            playButton.isEnabled = false
            
        }else{
            myAudioUploadRequest(recorder: audioRecorder)
            audioRecorder.stop()
            isRecording = false
            
            userDefaults.set(audioFileArray, forKey: "stringsArray")
//            print(url)
            userDefaults.set(url, forKey: audioFileArray.last!)
            userDefaultsIsNil = false
            
            userDefaults.set(userDefaultsIsNil, forKey: "nilFlag")
            
            recordButton.setImage(UIImage(named: "record"), for: .normal)
          
//            label.text = "待機中"
//            recordButton.setTitle("RECORD", for: .normal)
//            playButton.isEnabled = true
            
        }
    }
    
    func getURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
//        現在時刻をString型に変換して取得
        let now: String = "\(NSDate())"
        url = docsDirect.appendingPathComponent(now)
//        print(url)
        urlArray.append(url!)
        audioFileArray.append(now)
        return url!
    }
    
    func myAudioUploadRequest(recorder : AVAudioRecorder){
        
        let myUrl = URL(string: "http://localhost:5000/upload")!
        let fileurldata = try? Data(contentsOf: recorder.url)
        let request = NSMutableURLRequest(url: myUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let base64String = fileurldata!.base64EncodedString(options: [])
        //var err: NSError? = nil
        let params = ["sound":[ "content_type": "audio/aac", "filename":"test.flac", "file_data": base64String]]
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        

        let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
       
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
            var getJson: NSDictionary!
            var jsonIp = ""
            do {
                getJson = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                
//                仕様を決めてからか変更
                //print(getJson!)
                jsonIp = (getJson?["IsThreat"] as? String)!
                print (jsonIp)
                
                if jsonIp == "True"{
                    print("遷移")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toTwillio", sender: nil)
                    }
                }
            } catch {
                print ("json error")
                return
            }
            if error != nil {
                print(error!.localizedDescription)
                return
            }
        }
        task.resume() // this is needed to start the task
    }
    
}

