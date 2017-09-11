//
//  SCNVector3+Extension.swift
//  ARKitTestDemo
//
//  Created by DFHZ on 2017/9/11.
//  Copyright © 2017年 DFHZ. All rights reserved.
//

import Foundation
import ARKit

extension SCNVector3{
    
    /// 拿到镜头坐标
    ///
    /// - Parameter tranform: 矩阵
    /// - Returns: 返回的SCNVector3
    static func positionTranform(tranform:matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(tranform.columns.3.x, tranform.columns.3.y, tranform.columns.3.z)
    }
    
    
    /// 返回三维坐标系中两点之间的距离
    ///
    /// - Parameter vector: 传入的点
    /// - Returns: 返回的距离
    func getDistance(form vector:SCNVector3) -> Float {
        let distanceX = self.x - vector.x
        let distanceY = self.y - vector.y
        let distanceZ = self.z - vector.z
        
        return sqrt(distanceX*distanceX+distanceY*distanceY+distanceZ*distanceZ)
    }
    
    //划线的方法
    func addLine(to vector:SCNVector3,color:UIColor) -> SCNNode {
        let indices :[UInt32] = [0,1]//指数 指的是材料
        /*[0,1]表示经纬度 ---[什么东西：打算做成什么样子] */
        //创建一个集合容器
        let source = SCNGeometrySource(vertices:[self,vector])
        //创建一个几何元素
        let element = SCNGeometryElement(indices:indices,primitiveType:.line)
        //生成一个几何图形
        let geomtry = SCNGeometry(sources:[source],elements:[element])
        //几何添加纹理
        geomtry.firstMaterial?.diffuse.contents = color
        //创建节点
        let node = SCNNode(geometry:geomtry)
        return node
    }
}



extension SCNVector3:Equatable{
    
   /// 判断两个点是否是同一个点
   ///
   /// - Parameters:
   ///   - lhs: 第一个点
   ///   - rhs: 第二个点
   /// - Returns: 是否是同一个
   public static func ==(lhs:SCNVector3,rhs:SCNVector3) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}




