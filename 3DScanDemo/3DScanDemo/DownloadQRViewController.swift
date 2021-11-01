//
//  DownloadQRViewController.swift
//  3DScanDemo
//
//  Created by Michael on 2021/9/28.
//

import Foundation
import UIKit
import AVKit
import Alamofire
import AlamofireImage

class DownloadQRViewController: UIViewController {
    
    @IBOutlet weak var ugcVid: UIView!
    
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    private var appDelegate : AppDelegate?
    
    @IBOutlet weak var ugcQr: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        AF.request("https://houseofinnovationtrial.com/NikeHOI001/qrcode.php?scene=" + (appDelegate?.ugcFileName)!).responseImage {response in
            if case .success(let image) = response.result{
                print("https://houseofinnovationtrial.com/NikeHOI001/qrcode.php?scene=" + (self.appDelegate?.ugcFileName)!)
                print(response.data)
                self.ugcQr.image = image
            }else{
                self.ugcQr.image = nil
            }
        }
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let asset: AVAsset = AVAsset(url: URL(fileURLWithPath: documentsPath.appendingPathComponent("MyVideoCropped.mp4")))
        let playerItem = AVPlayerItem(asset: asset)
        self.queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.playerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: playerItem)
        
//        let ugcVidAvPlayer = AVPlayer(url: URL(fileURLWithPath: documentsPath.appendingPathComponent("MyVideoCropped.mp4")))
        let ugcPlayerLayer = AVPlayerLayer(player: queuePlayer)
        ugcPlayerLayer.frame = ugcVid.bounds
        ugcPlayerLayer.videoGravity = .resizeAspectFill
        ugcPlayerLayer.masksToBounds = true
        ugcPlayerLayer.cornerRadius = 100
        ugcVid.layer.addSublayer(ugcPlayerLayer)
//        ugcVidAvPlayer.play()
        queuePlayer?.play()
        ugcVid.layer.cornerRadius = 100
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 90) {
            self.performSegue(withIdentifier: "unwindSeg", sender: self)
        }
        
    }


}
