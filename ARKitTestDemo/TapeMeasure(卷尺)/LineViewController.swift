//
//  LineViewController.swift
//  ARKitTestDemo
//
//  Created by DFHZ on 2017/9/8.
//  Copyright © 2017年 DFHZ. All rights reserved.
//

import UIKit
import ARKit


class LineViewController: UIViewController,ARSCNViewDelegate {
    
    var mySenceView = ARSCNView()
    var mySession = ARSession()
    var configuration = ARWorldTrackingSessionConfiguration()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //全局追踪 重设节点 移除已存在的锚点
        mySession.run(configuration, options: [.resetTracking,.removeExistingAnchors]);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mySession.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mySenceView = ARSCNView.init(frame: self.view.bounds)
        mySenceView.delegate = self
        mySenceView.session = mySession
        self.view.addSubview(mySenceView)
    }
    
    //MARK 添加的使用方法
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("错误")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("结束")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("中断")
    }
}
