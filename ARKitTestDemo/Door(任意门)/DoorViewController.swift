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
        // 明确表示需要追踪水平面。设置后 scene 被检测到时就会调用 ARSCNViewDelegate 方法
        config.planeDetection = .horizontal
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
        myScene.autoenablesDefaultLighting = true
        // 开启 debug 选项以查看世界原点并渲染所有 ARKit 正在追踪的特征点
        myScene.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.view.addSubview(myScene)
    }
    //检测平面
    //侦测到锚点的时候调用这个方法
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        print("检测到平面了")
        // 检测到新平面时创建 SceneKit 平面以实现 3D 视觉化
        //锚点可以是任何形态，当前要检测平面，所以要把锚点放在我们检测到的平面上
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        //检测平面的宽和高
        //锚点的大小 == 我们所侦测到的水平面的大小
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage.init(named: "art.scnassets/door/grid.png")
        gridMaterial.lightingModel = .physicallyBased
        plane.materials = [gridMaterial]
        
        let planeNode = SCNNode(geometry:plane)//几何放到节点中
        //节点就在锚点的平面中心位置
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(Float(-.pi/2.0), 1.0, 0.0, 0.0)
        setTextureScale(plane: plane)
        node.addChildNode(planeNode)
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
    
    func setTextureScale(plane:SCNPlane) {
        let width = plane.width
        let height = plane.height
        
        // 平面的宽度/高度 width/height 更新时，我希望 tron grid material 覆盖整个平面，不断重复纹理。
        // 但如果网格小于 1 个单位，我不希望纹理挤在一起，所以这种情况下通过缩放更新纹理坐标并裁剪纹理
        let material = plane.materials.first
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 1)
        material?.diffuse.wrapS = .repeat
        material?.diffuse.wrapT = .repeat
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
