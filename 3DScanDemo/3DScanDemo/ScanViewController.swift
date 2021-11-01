//
//  ScanViewController.swift
//  3DScanDemo
//
//  Created by Michael on 2021/8/16.
//

import Foundation
import StandardCyborgNetworking
import StandardCyborgFusion
import StandardCyborgUI

class ScanViewController: UIViewController, ScanningViewControllerDelegate {
    private var scenePreviewVC: ScenePreviewViewController?
//    private var pointCloudSaved: SCPointCloud?
    private var scanViewController: ScanningViewController?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        let vc = ScanningViewController(delegate: self)
        scanViewController = vc
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        if (appDelegate.isFinished == false){
            print("started")
            present(scanViewController!, animated: true)
        }
        
    }
    
    // MARK: - ScanningViewControllerDelegate
    
    func scanningViewControllerDidCancel(_ controller: ScanningViewController) {
        
        dismiss(animated: true)
    }

    func scanningViewController(_ controller: ScanningViewController, didScan pointCloud: SCPointCloud) {
        let vc = ScenePreviewViewController(pointCloud: pointCloud, meshTexturing: controller.meshTexturing, landmarks: nil)
        vc.rightButton.addTarget(self, action: #selector(CheckFinalPreview), for: UIControl.Event.touchUpInside)
        vc.rightButton.setTitle("RESCAN", for: UIControl.State.normal)
        vc.rightButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        vc.rightButton.setImage(UIImage(named: "DoneButton"), for: UIControl.State.normal)
        
        vc.leftButton.addTarget(self, action: #selector(rescanPreviewedSceneTapped), for: UIControl.Event.touchUpInside)
        vc.leftButton.setTitle("DONE", for: UIControl.State.normal)
        vc.leftButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        vc.leftButton.setImage(UIImage(named: "RescanButton"), for: UIControl.State.normal)
        
        scenePreviewVC = vc
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        presentedViewController?.present(vc, animated: true)
    }
    
    @objc func CheckFinalPreview(){
        
        
        // wait for user login at control ipad
        scenePreviewVC?.generatingView.isHidden = false
        
        // for debugging only
        
        self.dismiss(animated: false, completion: {
            self.dismiss(animated: false, completion: nil)
            self.performSegue(withIdentifier: "FinalSegue", sender: nil)
        })
        
//        appDelegate.userInfoSocketClient.on("/OnStartOpening") { data, ack in
//            print("GOT USER")
//            self.appDelegate.isFinished = true
//            var dictres = data[0] as! Dictionary<String, Any>
//            self.appDelegate.playerSex = dictres["gender"] as! Int
//            self.appDelegate.playerMode = dictres["product"] as! Int
//            
//            self.dismiss(animated: false, completion: {
//                self.dismiss(animated: false, completion: nil)
//                self.performSegue(withIdentifier: "FinalSegue", sender: nil)
//            })
//        }
    }

    
    func topViewController() -> UIViewController? {
        
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
            
        } else {
            
            return nil
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "FinalSegue"){
            print("GOING TO FINAL PREVIEW")
            

            let finalPreviewController = segue.destination as! FinalPreviewViewController
            finalPreviewController.sceneToDisplay = scenePreviewVC?.sceneView.scene
        }
    }
    
    @objc func rescanPreviewedSceneTapped(){
        print("Rescan...")
        presentedViewController?.dismiss(animated: true)
    }
    
    
}
