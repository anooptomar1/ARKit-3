//
//  ARSCNView+Extension.swift
//  ARKitTestDemo
//
//  Created by DFHZ on 2017/9/11.
//  Copyright © 2017年 DFHZ. All rights reserved.
//

import Foundation
import ARKit

extension ARSCNView{
    
    /// 拿到三维坐标
    ///
    /// - Parameter position: 当前的位置
    /// - Returns: 返回的坐标位置
    func worldVector(for position:CGPoint) -> SCNVector3? {
        let results = self.hitTest(position, types: [.featurePoint])
        guard let result = results.first else {
            return nil
        }
        return SCNVector3.positionTranform(tranform: result.worldTransform)
    }
}

