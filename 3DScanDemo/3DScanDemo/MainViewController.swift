//
//  ViewController.swift
//  3DScanDemo
//
//  Created by Michael on 2021/8/16.
//
 
import UIKit
import SocketIO

class MainViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // socket stuff
        appDelegate.userInfoSocketClient.on("/OnStartOpening") {data, ack in
            print("OnStartOpening")
            self.appDelegate.userInfoSocketClient.off("/OnStartOpening")
            self.appDelegate.isFinished = false
            print(data[0])
//            self.appDelegate.playerMode = data[0] as? Int
//            self.appDelegate.playerSex = data[1] as? Int
//            
            self.performSegue(withIdentifier: "startSeg", sender: self)
        }
    }

    @IBAction func didTapButton(){
        self.appDelegate.isFinished = false
        performSegue(withIdentifier: "startSeg", sender: self)
    }
    
    @IBAction func unwindToMain(_ unwindSegue: UIStoryboardSegue) {
        // let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }

}

