//
//  AppDelegate.swift
//  3DScanDemo
//
//  Created by Michael on 2021/8/16.
//

import UIKit
import QCloudCOSXML
import SocketIO

@main
class AppDelegate: UIResponder, UIApplicationDelegate, QCloudSignatureProvider {

    public let userInfoServerURL = "http://10.0.50.82:8088"
    public lazy var userInfoServerManager = SocketManager(socketURL: URL(string: userInfoServerURL)!, config: [.log(false), .compress, .reconnectWait(3), .reconnectWaitMax(-1)])
    public lazy var userInfoSocketClient = userInfoServerManager.defaultSocket
    
    var playerSex : Int?
    var playerMode : Int?
    var ugcFileName : String?
    var isFinished = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // for debugging only
        playerSex = Int.random(in: 0..<2)
        playerMode = Int.random(in: 0..<3)
        
        self.userInfoSocketClient.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        self.userInfoSocketClient.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnected")
        }
        
        self.userInfoSocketClient.connect();
        
        // COS authentiation stuff
        let config = QCloudServiceConfiguration.init();
        let endpoint = QCloudCOSXMLEndPoint.init();
        //服务地域简称，例如广州地域是 ap-guangzhou
        endpoint.regionName = "ap-nanjing";
        // 使用 HTTPS
        endpoint.useHTTPS = true;
        config.endpoint = endpoint;
        // 密钥提供者为自己
        config.signatureProvider = self;
        // 初始化 COS 服务示例
        QCloudCOSXMLService.registerDefaultCOSXML(with: config);
        QCloudCOSTransferMangerService.registerDefaultCOSTransferManger(
          with: config);
        
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func signature(with fileds: QCloudSignatureFields!,
                  request: QCloudBizHTTPRequest!,
                  urlRequest urlRequst: NSMutableURLRequest!,
                  compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
      let credential = QCloudCredential.init();
      //SECRETID和SECRETKEY请登录访问管理控制台进行查看和管理
      credential.secretID = "AKIDOXljQq9RLxJciWRdy3rKdkCsrZ3FNejV"; // 永久密钥 SecretId
      credential.secretKey = "lumNguGPIuEfrme5fzamJ0QZuWMvDhPO"; // 永久密钥 SecretKey
       // 使用永久密钥计算签名
      let auth = QCloudAuthentationV5Creator.init(credential: credential);
      let signature = auth?.signature(forData: urlRequst)
      continueBlock(signature,nil);
    }


}

