//
//  FinalPreviewViewController.swift
//  3DScanDemo
//
//  Created by Michael on 2021/9/8.
//


import SceneKit
import ReplayKit
import CoreImage
import Photos
import QCloudCOSXML

class FinalPreviewViewController : UIViewController {
    
    
    @IBOutlet weak var BGColor: UIView!
    @IBOutlet weak var BGVid: UIView!
    @IBOutlet weak var MidLayer: UIImageView!
    @IBOutlet weak var FrontVi: UIView!
    @IBOutlet weak var ImgCover: UIImageView!
    
    @IBOutlet public weak var scnView: SCNView!

    @IBOutlet weak var storm_male: UIImageView!
    @IBOutlet weak var storm_female: UIImageView!
    @IBOutlet weak var dri_male: UIImageView!
    @IBOutlet weak var dri_female: UIImageView!
    @IBOutlet weak var therma_male: UIImageView!
    @IBOutlet weak var therma_female: UIImageView!
    
    @IBOutlet weak var UGCView: UIView!
    
    public var sceneToDisplay : SCNScene?
    private var recorder: Recorder?
    private var videoOutputURL: URL?
    private var videoWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?
    private var appDelegate: AppDelegate?
    private var currentFinalUGCPath: URL?
    private var bgQueuePlayer : AVQueuePlayer?
    private var frontQueuePlayer : AVQueuePlayer?
    private var bgPlayerLooper : AVPlayerLooper?
    private var frontPlayerLooper : AVPlayerLooper?
    private var frameCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        scnView.scene = sceneToDisplay!
        sceneToDisplay?.background.contents = UIColor.clear
        if let pov = scnView.pointOfView {
            pov.localTranslate(by: SCNVector3(-0.05, -0.1, 0.5))
        }
        
        let driBgVidPath = Bundle.main.path(forResource: "driBg", ofType: "mp4")
        let stormBgVidPath = Bundle.main.path(forResource: "stormBg", ofType: "mp4")
        let thermalBgVidPath = Bundle.main.path(forResource: "thermaBg", ofType: "mp4")
        let driFrontVidPath = Bundle.main.path(forResource: "driCoverVId", ofType: "mp4")
        let stormFrontVidPath = Bundle.main.path(forResource: "stormCoverVid", ofType: "mp4")
        let thermalFrontVidPath = Bundle.main.path(forResource: "thermaCoverVid", ofType: "mp4")
        var finalBgVidPath = ""
        var finalFrontVidPath = ""
        if (appDelegate?.playerMode == 0){
            //drifit
            finalBgVidPath = driBgVidPath!
            finalFrontVidPath = driFrontVidPath!
            MidLayer.image = UIImage(named: "dri-fitMid")
            if (appDelegate?.playerSex == 0){
                //male
                dri_male.isHidden = false
            }else{
                dri_female.isHidden = false
            }
            
            BGColor.backgroundColor = UIColor(red: 219/255, green: 44/255, blue: 19/255, alpha: 1)
        }else if (appDelegate?.playerMode == 1){
            //stormfit
            finalBgVidPath = stormBgVidPath!
            finalFrontVidPath = stormFrontVidPath!
            MidLayer.image = UIImage(named: "storm-fitMid")
            if (appDelegate?.playerSex == 0){
                //male
                storm_male.isHidden = false
            }else{
                storm_female.isHidden = false
            }
            BGColor.backgroundColor = UIColor.black
            
        }else{
            //thermafit
            finalBgVidPath = thermalBgVidPath!
            finalFrontVidPath = thermalFrontVidPath!
            MidLayer.image = UIImage(named: "therma-fitMid")
            if (appDelegate?.playerSex == 0){
                //male
                therma_male.isHidden = false
            }else{
                therma_female.isHidden = false
            }
            BGColor.backgroundColor = UIColor.white
        }
        
        print(finalBgVidPath)
        print(finalFrontVidPath)
        
        let bgAsset: AVAsset = AVAsset(url: URL(fileURLWithPath: finalBgVidPath))
        let bgPlayerItem = AVPlayerItem(asset: bgAsset)
        self.bgQueuePlayer = AVQueuePlayer(playerItem: bgPlayerItem)
        self.bgPlayerLooper = AVPlayerLooper(player: bgQueuePlayer!, templateItem: bgPlayerItem)
        
        let frontAsset: AVAsset = AVAsset(url: URL(fileURLWithPath: finalFrontVidPath))
        let frontPlayerItem = AVPlayerItem(asset: frontAsset)
        self.frontQueuePlayer = AVQueuePlayer(playerItem: frontPlayerItem)
        self.frontPlayerLooper = AVPlayerLooper(player: frontQueuePlayer!, templateItem: frontPlayerItem)
        
        let bgPlayerLayer = AVPlayerLayer(player: bgQueuePlayer)
        bgPlayerLayer.frame = BGVid.bounds
        bgPlayerLayer.videoGravity = .resizeAspectFill
        BGVid.layer.addSublayer(bgPlayerLayer)
        
        let frontPlayerLayer = AVPlayerLayer(player: frontQueuePlayer)
        frontPlayerLayer.frame = FrontVi.bounds
        frontPlayerLayer.videoGravity = .resizeAspectFill
        FrontVi.layer.addSublayer(frontPlayerLayer)
        
        frontQueuePlayer!.play()
        bgQueuePlayer!.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("Started Recording")
            self.startRecording()
        }
        
        
    }
    
    func startRecording() {
            //Use ReplayKit to record the screen

            //Create the file path to write to
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            self.videoOutputURL = URL(fileURLWithPath: documentsPath.appendingPathComponent("MyVideo.mp4"))

            //Check the file does not already exist by deleting it if it does
            do {
                try FileManager.default.removeItem(at: videoOutputURL!)
            } catch {}


            do {
                try videoWriter = AVAssetWriter(outputURL: videoOutputURL!, fileType: AVFileType.mp4)
            } catch let writerError as NSError {
                print("Error opening video file", writerError)
                videoWriter = nil;
                return;
            }

            let videoCompressionProps: Dictionary<String, Any> = [
                AVVideoAverageBitRateKey : 10000000,
                AVVideoQualityKey: 0.95,
                AVVideoExpectedSourceFrameRateKey : 30,
            ]
            //Create the video settings
            let videoSettings: [String : Any] = [
                AVVideoCodecKey  : AVVideoCodecType.hevc,
                AVVideoWidthKey  : 1668,  //Replace as you need
                AVVideoHeightKey : 2338,   //Replace as you need
                AVVideoCompressionPropertiesKey: videoCompressionProps
            ]

            //Create the asset writer input object whihc is actually used to write out the video
            //with the video settings we have created
            videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
            videoWriter!.add(videoWriterInput!)

            //Tell the screen recorder to start capturing and to call the handler when it has a
            //sample
            RPScreenRecorder.shared().startCapture(handler: { (cmSampleBuffer, rpSampleType, error) in

                guard error == nil else {
                    //Handle error
                    print("Error starting capture");
                    return;
                }

                switch rpSampleType {
                    case RPSampleBufferType.video:

                        if self.videoWriter!.status == AVAssetWriter.Status.unknown {

                            if (( self.videoWriter?.startWriting ) != nil) {
                                print("Starting writing");
//                                self.startedRecording = true
                                self.videoWriter!.startWriting()
                                self.videoWriter!.startSession(atSourceTime:  CMSampleBufferGetPresentationTimeStamp(cmSampleBuffer))
                            }
                        }

                        if self.videoWriter!.status == AVAssetWriter.Status.writing {
                            if (self.videoWriterInput!.isReadyForMoreMediaData == true) {
                                print("Writting a sample");
                                if  self.videoWriterInput!.append(cmSampleBuffer) == false {
                                    print(" we have a problem writing video")
                                }else{
                                    self.frameCount += 1
                                    if (self.frameCount == 850){
                                        self.stopRecording()
                                    }
                                }
                                
                            }
                    }
                default: break
                }
            }
        )
    }
    
    func stopRecording() {
        //Stop Recording the screen
        RPScreenRecorder.shared().stopCapture( handler: { (error) in
            print("stopping recording");
        })

        print(frameCount)
        self.videoWriterInput!.markAsFinished();
        self.videoWriter!.finishWriting {
            print("finished writing video");
            
            //Now save the video
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoOutputURL!)
            }) { saved, error in
                if saved {
                    self.cropVideo(self.videoOutputURL!){ (_) -> () in
                        print("Cropp finished")
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.currentFinalUGCPath!)
                        }) { saved, error in
                            if saved {
                                print("saved cropped version")
                            }
                            if error != nil {
                                print("cropped video did not save for some reason", error.debugDescription);
                            }
                        }
                        
                        // stopping upload for local testing
//                        self.uploadToCOS()
                    }
                }
                if error != nil {
                    print("Video did not save for some reason", error.debugDescription);
//                    debugPrint(error?.localizedDescription ?? "error is nil");
                }
            }
        }
    }
    
    func cropVideo( _ outputFileUrl: URL, callback: @escaping ( _ newUrl: URL ) -> () )
    {
        // Get input clip
        let videoAsset: AVAsset = AVAsset( url: outputFileUrl )
        let clipVideoTrack = videoAsset.tracks( withMediaType: AVMediaType.video ).first! as AVAssetTrack

        // Make video to square
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize( width: 1171, height: clipVideoTrack.naturalSize.height )
        videoComposition.frameDuration = CMTimeMake( value: 1, timescale: 60 )

        // Rotate to portrait
        let transformer = AVMutableVideoCompositionLayerInstruction( assetTrack: clipVideoTrack )
        let transform1 = CGAffineTransform( translationX: -(1668  - 1171)/2, y: 0 )
        //          let transform2 = transform1.rotated(by: CGFloat( M_PI_2 ) )
        transformer.setTransform( transform1, at: CMTime.zero)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds( 15, preferredTimescale: 60 ) )

        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]

        // Export
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let croppedOutputFileUrl = URL( fileURLWithPath: documentsPath.appendingPathComponent("MyVideoCropped.mp4") )
        do {
            try FileManager.default.removeItem(at: croppedOutputFileUrl)
        } catch {}
        currentFinalUGCPath = croppedOutputFileUrl

        // or can use AVAssetExportPresetHighestQuality, but doesnt seem to have much difference despite having a larger filesize
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHEVCHighestQuality)!
        
        exporter.videoComposition = videoComposition
        exporter.outputURL = croppedOutputFileUrl
        exporter.outputFileType = AVFileType.mp4
        exporter.fileLengthLimit = 1048576 * 50

        exporter.exportAsynchronously( completionHandler: { () -> Void in
            print(exporter.status.rawValue)
            print(exporter.error.debugDescription)
          DispatchQueue.main.async(execute: {
              callback( croppedOutputFileUrl )
          })
        })
    }
    
    func uploadToCOS(){
        let put:QCloudCOSXMLUploadObjectRequest = QCloudCOSXMLUploadObjectRequest<AnyObject>();
        // 存储桶名称，格式为 BucketName-APPID
        put.bucket = "nike-cold-weather-1257459029";
        // 对象键，是对象在 COS 上的完整路径，如果带目录的话，格式为 "video/xxx/movie.mp4"
        var fn = returnTime()
        appDelegate?.ugcFileName = fn
        put.object = fn + ".mp4"
        //需要上传的对象内容。可以传入NSData*或者NSURL*类型的变量
        print("************ TRYING TO UPLOAD: " + ((currentFinalUGCPath!.absoluteString)))
        put.body = currentFinalUGCPath! as AnyObject;
        //监听上传结
        put.setFinish { (result, error) in
          // 获取上传结果
          if error != nil{
              print("************** GOT ERROR WTFFFFFFFFF")
              print(error!);
          }else{
            print(result!);
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                // UIView usage
                self.performSegue(withIdentifier: "ScanSegue", sender: self)
            }
          }
        }
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(put);
    }
    
    func returnTime() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddHHmm"
        return dateFormatter.string(from: NSDate() as Date)
    }
}
