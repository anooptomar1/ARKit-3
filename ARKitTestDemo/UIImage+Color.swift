//
//  UIImage+Color.swift
//  ARKitTestDemo
//
//  Created by DFHZ on 2017/9/11.
//  Copyright © 2017年 DFHZ. All rights reserved.
//

import Foundation

extension UIImage{
    /// 根据颜色值生成图片
    ///
    /// - Parameter color: 颜色值
    /// - Returns: 返回的图片
    class func imageWithColor(color:UIColor) -> UIImage {
        let rect = CGRect.init(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        //开启位图上下文
        UIGraphicsBeginImageContext(rect.size)
        //获取位图上下文
        let context = UIGraphicsGetCurrentContext()
        //使用颜色填充上下文
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
