//
//  DoorViewController.swift
//  ARKitTestDemo
//
//  Created by DFHZ on 2017/9/12.
//  Copyright © 2017年 DFHZ. All rights reserved.
//

import UIKit
import ARKit

class DoorViewController: ZJBaseViewController,ARSCNViewDelegate {
    
    var myScene:ARSCNView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let config = ARWorldTrackingSessionConfiguration()
        myScene.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        myScene.session.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myScene = ARSCNView.init(frame: self.view.bounds)
        myScene.delegate = self
        myScene.showsStatistics = true
        self.view.addSubview(myScene)
    }
    //检测平面
    //侦测到锚点的时候调用这个方法
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            //锚点可以是任何形态，当前要检测平面，所以要把锚点放在我们检测到的平面上
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            //检测平面的宽和高
            //锚点的大小 == 我们所侦测到的水平面的大小
            let planeNode = SCNNode()//几何放到节点中
            //节点就在锚点的平面中心位置
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            //添加内容
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage.init(named: "art.scnassets/door/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
        }
    }
    
    //点击开始添加节点
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //是否是第一次点击
        if let touch = touches.first{
            //2D屏幕上点击的位置
            let touchLocation = touch.location(in: myScene)
            //将2D屏幕上的位置 转换成手机屏幕里的3D坐标
            let results = myScene.hitTest(touchLocation, types: .featurePoint)
            //existingPlaneUsingExtent 只在侦测到的平面范围上点击才有作用
            //点击结果是否是他第一次
            if let hitResult = results.first{
                let boxScene = SCNScene.init(named: "art.scnassets/door/portal.scn")!
                if let boxNode = boxScene.rootNode.childNode(withName: "portal", recursively: true){
                    boxNode.position = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y+0.05, hitResult.worldTransform.columns.3.z)
                    myScene.scene.rootNode.addChildNode(boxNode)
                }
            }
        }
    }
    
    //MARK: ARSCNView代理方法
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
