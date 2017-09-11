//
//  Line.swift
//  ARKitTestDemo
//
//  Created by DFHZ on 2017/9/11.
//  Copyright © 2017年 DFHZ. All rights reserved.
//

import Foundation
import ARKit

//定义枚举
enum LengthUnit {
    case meter,cenitMeter,inch
    //定义返回值
    var factor:Float {
        switch self {
        case .meter:
            return 1.0
        case .cenitMeter:
            return 100.0
        case .inch:
            return 39.3700787
        }
    }
    //定义返回字符串
    var name: String{
        switch self {
        case .meter:
            return "m"
        case .cenitMeter:
            return "cm"
        case .inch:
            return "inch"
        }
    }
}

class Line {
    
    var color = UIColor.orange
    var startNode:SCNNode
    var endNode:SCNNode
    var textNode:SCNNode
    var text:SCNText
    var lineNode:SCNNode?
    
    let sceneView:ARSCNView
    let startVector:SCNVector3
    var unit:LengthUnit
    
    init(sceneView: ARSCNView,startVector: SCNVector3,unit: LengthUnit) {
        //创建节点(开始，结束，线，数字，单位)
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        //设置初始节点
        let dot = SCNSphere(radius:0.5)
        dot.firstMaterial?.diffuse.contents = color
        dot.firstMaterial?.lightingModel = .constant//不会产生阴影
        dot.firstMaterial?.isDoubleSided = true //两面都是一样的光
        
        startNode = SCNNode(geometry: dot)
        startNode.scale = SCNVector3(1/500.0,1/500.0,1/500.0)
        startNode.position = startVector
        sceneView.scene.rootNode.addChildNode(startNode)
        
        endNode = SCNNode(geometry: dot)
        endNode.scale = SCNVector3(1/500.0,1/500.0,1/500.0)
        
        text = SCNText(string: "", extrusionDepth: 0.1)
        text.font = .systemFont(ofSize: 5)
        text.firstMaterial?.diffuse.contents = color
        text.firstMaterial?.lightingModel = .constant
        text.firstMaterial?.isDoubleSided = true
        text.alignmentMode = kCAAlignmentCenter //对齐方式
        text.truncationMode = kCATruncationMiddle
        //包装文字的节点
        let textWrapperNode = SCNNode(geometry:text);
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)//文字始终对着我
        textWrapperNode.scale = SCNVector3(1/500.0,1/500.0,1/500.0)
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        //文字的约束无法说出在那个位置，给文字设置约束，让文字节点一直在线的中间
        let constraint =  SCNLookAtConstraint(target: sceneView.pointOfView)
        //SCNLookAtConstraint 是一个约束 让他跟随我们设定的目标 永远的面相使用者
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(textNode)
   }
    
    func updateNode(to vector:SCNVector3) {
        lineNode?.removeFromParentNode()//移除所有的线
        lineNode = startVector.addLine(to: vector, color: color)
        sceneView.scene.rootNode.addChildNode(lineNode!)
        //更新文字
        text.string = distance(to: vector)
        textNode.position = SCNVector3Make((startVector.x+vector.x)/2.0, (startVector.y+vector.y)/2.0,(startVector.z+vector.z)/2.0)
        //结束节点的位置
        endNode.position = vector;
        if endNode.parent == nil {
            sceneView.scene.rootNode.addChildNode(endNode)
        }
    }
    
    ///计算距离
    func distance(to vector:SCNVector3) -> String {
        return String(format:"%.2f %@",startVector.getDistance(form: vector)*unit.factor,unit.name)
    }
    
    ///移除节点
    func remove()  {
        startNode.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
    }
}
